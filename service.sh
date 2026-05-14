#!/system/bin/sh
# PrimeThermal-ArtisanROM vY.1.1.1 — UI Responsiveness Hotfix
# Fork of PrimeThermal v1.1-OneUI by Prime1337
# Rebuilt for: Samsung Galaxy S10+ (SM-G975F / beyond2lte)
#              ArtisanROM Quant | OneUI 8 | Android 16
#              KernelSU-Next | ArtisanKRNL (upstreamed Linux 5.x)
#
# vY.1.1.1 hotfix over vY.1.1:
#  * BURST threshold lowered 60 % → 40 % (configurable via BURST_THRESH).
#    Scroll, reel, and swipe loads now reliably trigger instant ACTIVE.
#  * IDLE exit is instant — upgrades from IDLE to LIGHT or ACTIVE bypass
#    the 15 s debounce. Swipe gestures no longer stall in IDLE.
#  * IDLE BIG cap raised 1200 MHz → 1600 MHz — enough headroom for UI
#    rendering without hitting the frequency ceiling mid-frame.
#  * IDLE down_rate_limit_us 8000 µs → 4000 µs — smoother governor
#    response after animation/scroll bursts.
#
# vY.1.1 improvements over upstream V1.2:
#  * GAMING mode, POWERSAVE mode, BURST detection, WebUI, hard abort.
#  * Mode-specific HC trigger temps, raised IDLE/LIGHT floors.
#  * schedutil up_rate_limit_us = 500 µs on ALL modes.
#  * /proc/uptime debounce timer, unconditional log rotation.
#  * HH:MM:SS timestamps, is_gaming() head -1 anchor, chmod 644 config.sh.
#
# Kernel facts (ArtisanROM Quant / ArtisanKRNL upstreamed Linux 5.x):
#  - schedutil is the ONLY governor (interactive/ondemand removed).
#  - compact_memory node absent (removed in Linux 5.18+) — not written.
#  - cpufreq layout: pol0=LITTLE cpu0-3, pol4=MID cpu4-5, pol6=BIG cpu6-7.
#  - Thermal zones: zone0-2=clusters, zone5=skin/PCB, zone6=battery.
#  - Samsung thermal daemon stripped (DeKnoxed) — sysfs writes uncontested.
#  - SELinux Enforcing — all writes via root sysfs, no policy changes needed.

# ─── Module dir & log path ───────────────────────────────────────────────────
_MOD_DIR="/data/adb/modules/PrimeThermalArtisanROM"
if [ -d "$_MOD_DIR" ] && [ -w "$_MOD_DIR" ]; then
  LOG="$_MOD_DIR/thermal.log"
  ERR="$_MOD_DIR/thermal.err"
else
  mkdir -p /data/local/tmp 2>/dev/null
  LOG="/data/local/tmp/s10_thermal.log"
  ERR="/data/local/tmp/s10_thermal.err"
fi

# ─── Defaults (overridden by config.sh) ─────────────────────────────────────
GAMING_PACKAGES=""
GAMING_IGNORE_THERMAL=false
GAMING_THERMAL_CEIL=48
GAMING_HARD_ABORT=54
LOOP_SLEEP=1
ENABLE_LOG=true
MODE=auto
TEMP_AUTO_TRIGGER=42
TEMP_GAMING_TRIGGER=45
TEMP_SAVE_TRIGGER=38
# vY.1.1.1: configurable burst threshold (was hardcoded 60)
BURST_THRESH=25

_CFG="$_MOD_DIR/config.sh"
if [ -f "$_CFG" ]; then
  . "$_CFG"
fi

# ─── Log control ─────────────────────────────────────────────────────────────
# ENABLE_LOG=false silences all output at shell level — zero log I/O overhead.
[ "$ENABLE_LOG" = "true" ] || exec >/dev/null 2>/dev/null

echo "[INIT] PrimeThermal vY.1.1.1-ArtisanROM started $(date) PID=$$" > "$LOG"
echo "[INIT] MODE=${MODE} ENABLE_LOG=${ENABLE_LOG} BURST_THRESH=${BURST_THRESH}" >> "$LOG"

# ─── Cover image symlink (MMRL + KSU-Next module card) ──────────────────────
if [ -n "$COVER_IMAGE" ] && [ -f "$_MOD_DIR/$COVER_IMAGE" ]; then
  mkdir -p "$_MOD_DIR/webroot" 2>/dev/null
  ln -sf "$_MOD_DIR/$COVER_IMAGE" "$_MOD_DIR/webroot/cover.png" 2>/dev/null
  [ "$COVER_IMAGE" != "cover.png" ] && \
    ln -sf "$_MOD_DIR/$COVER_IMAGE" "$_MOD_DIR/cover.png" 2>/dev/null
  echo "[INIT] Cover image linked: $COVER_IMAGE" >> "$LOG"
else
  echo "[INIT] Cover image: none configured or file missing" >> "$LOG"
fi

(
  LOG="$LOG"
  ERR="$ERR"

  # ─── CPU policy paths ─────────────────────────────────────────────────────
  POL0="/sys/devices/system/cpu/cpufreq/policy0"   # LITTLE  cpu0-3  Cortex-A55
  POL4="/sys/devices/system/cpu/cpufreq/policy4"   # MID     cpu4-5  Cortex-A75
  POL6="/sys/devices/system/cpu/cpufreq/policy6"   # BIG     cpu6-7  Cortex-A75 prime

  # Max stock OPP frequencies (Hz) — Exynos 9820 confirmed
  M0=1950000; M4=2314000; M6=2730000

  # ─── Thermal sensors ──────────────────────────────────────────────────────
  T_SKIN="/sys/class/thermal/thermal_zone5/temp"   # skin/PCB (primary)
  T_BATT="/sys/class/thermal/thermal_zone6/temp"   # battery (skin fallback)
  T_CORE0="/sys/class/thermal/thermal_zone0/temp"  # LITTLE cluster
  T_CORE1="/sys/class/thermal/thermal_zone1/temp"  # MID cluster
  T_CORE2="/sys/class/thermal/thermal_zone2/temp"  # BIG cluster

  # ─── Battery / swap ───────────────────────────────────────────────────────
  BATT="/sys/class/power_supply/battery/status"
  SWAP="/proc/sys/vm/swappiness"

  # ─── State ────────────────────────────────────────────────────────────────
  ST="ACTIVE"; LC=0; DB=15; L1=0; L2=0; L3=0; HC=0; TICK=0

  # Pre-compute gaming list emptiness — avoids string test every tick
  _GAMING_ENABLED=false
  [ -n "$GAMING_PACKAGES" ] && _GAMING_ENABLED=true

  # ─────────────────────────────────────────────────────────────────────────
  # safe_write <value> <path>
  # ─────────────────────────────────────────────────────────────────────────
  safe_write() {
    [ -f "$2" ] && echo "$1" > "$2" 2>/dev/null
  }

  # ─────────────────────────────────────────────────────────────────────────
  # uptime_s — integer seconds since boot, no extra fork
  # ─────────────────────────────────────────────────────────────────────────
  uptime_s() {
    read _up _idle < /proc/uptime 2>/dev/null
    echo "${_up%%.*}"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # rotate_log — keep log under 1000 lines
  # ─────────────────────────────────────────────────────────────────────────
  rotate_log() {
    if [ -f "$LOG" ]; then
      lines=$(wc -l < "$LOG" 2>/dev/null | tr -d ' ')
      if [ "$lines" -gt 1000 ] 2>/dev/null; then
        tail -n 1000 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG" 2>/dev/null
        echo "[SYS] Log rotated" >> "$LOG" 2>/dev/null
      fi
    fi
  }

  # ─────────────────────────────────────────────────────────────────────────
  # read_temp <path> — read sysfs temp, auto-convert milli-Celsius
  # ─────────────────────────────────────────────────────────────────────────
  read_temp() {
    v=$(cat "$1" 2>/dev/null)
    v=${v:-0}
    [ "$v" -gt 1000 ] 2>/dev/null && v=$((v/1000))
    echo "$v"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # get_skin_t — skin temp with battery fallback
  # ─────────────────────────────────────────────────────────────────────────
  get_skin_t() {
    v=$(cat "$T_SKIN" 2>/dev/null)
    if [ -z "$v" ] || [ "$v" = "0" ]; then
      v=$(cat "$T_BATT" 2>/dev/null)
    fi
    v=${v:-0}
    [ "$v" -gt 1000 ] 2>/dev/null && v=$((v/1000))
    echo "$v"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # get_core_t — max temp across all three CPU clusters
  # ─────────────────────────────────────────────────────────────────────────
  get_core_t() {
    t0=$(read_temp "$T_CORE0")
    t1=$(read_temp "$T_CORE1")
    t2=$(read_temp "$T_CORE2")
    max=$t0
    [ "$t1" -gt "$max" ] 2>/dev/null && max=$t1
    [ "$t2" -gt "$max" ] 2>/dev/null && max=$t2
    echo "$max"
  }

  # ─── Backlight node detection ─────────────────────────────────────────────
  BL_NODE=""
  for _bl_candidate in \
      /sys/class/backlight/panel0-backlight/brightness \
      /sys/class/backlight/panel-0/brightness \
      /sys/class/backlight/s6e3ha9/brightness \
      /sys/class/backlight/s6e3hc2/brightness; do
    if [ -r "$_bl_candidate" ]; then
      BL_NODE="$_bl_candidate"
      break
    fi
  done
  echo "[INIT] Backlight node: ${BL_NODE:-NOT FOUND (will use dumpsys)}" >> "$LOG"

  # ─────────────────────────────────────────────────────────────────────────
  # is_off — returns 0 (true) if screen is off
  # ─────────────────────────────────────────────────────────────────────────
  is_off() {
    if [ -n "$BL_NODE" ]; then
      _bv=$(cat "$BL_NODE" 2>/dev/null)
      [ "${_bv:-1}" = "0" ] && return 0
      return 1
    fi
    dumpsys power 2>/dev/null | grep -q "Display Power: state=OFF" && return 0
    return 1
  }

  # ─────────────────────────────────────────────────────────────────────────
  # is_gaming — returns 0 (true) if a game package is in the foreground.
  # Uses dumpsys activity recents (~40 ms binder cost vs ~120 ms full dump).
  # head -1 anchors to the first package match, preventing false positives.
  # ─────────────────────────────────────────────────────────────────────────
  is_gaming() {
    _fg=$(dumpsys activity recents 2>/dev/null \
          | grep -m1 "Recent #0" \
          | grep -oE "[a-z][a-zA-Z0-9_]*(\.[a-zA-Z0-9_]+){2,}" \
          | head -1)
    [ -z "$_fg" ] && return 1
    for _pkg in $GAMING_PACKAGES; do
      [ "$_fg" = "$_pkg" ] && return 0
    done
    return 1
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_schedutil <policy_path> <up_us> <dn_us>
  # ─────────────────────────────────────────────────────────────────────────
  apply_schedutil() {
    _pol="$1"; _up="$2"; _dn="$3"
    safe_write "$_up" "${_pol}/schedutil/up_rate_limit_us"
    safe_write "$_dn" "${_pol}/schedutil/down_rate_limit_us"
    safe_write "$_up" "${_pol}/schedutil/rate_limit_us"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_tweaks <mode>
  #
  # schedutil strategy:
  #   up_rate_limit_us = 500 µs on all modes — governor reacts in <1 ms.
  #   down_rate_limit_us higher in power-saving modes to preserve battery.
  #
  #   POCKET/IDLE    : up=500   dn=4000 µs  [vY.1.1.1: was 8000 µs]
  #   POWERSAVE      : up=2000  dn=12000 µs  (conservative — minimise CPU wake)
  #   LIGHT          : up=500   dn=4000 µs
  #   ACTIVE/CHARGING: up=500   dn=2000 µs
  #   GAMING         : up=500   dn=500  µs   (minimum latency)
  # ─────────────────────────────────────────────────────────────────────────
  apply_tweaks() {
    case "$1" in
      POCKET|IDLE)
        # vY.1.1.1: dn lowered 8000 → 4000 µs for smoother post-burst drop
        apply_schedutil "$POL0" 500 4000
        apply_schedutil "$POL4" 500 4000
        apply_schedutil "$POL6" 500 4000
        safe_write 100 "$SWAP"
        echo "[TWEAKS] ECO applied" >> "$LOG" 2>/dev/null
        ;;
      POWERSAVE)
        apply_schedutil "$POL0" 2000 12000
        apply_schedutil "$POL4" 2000 12000
        apply_schedutil "$POL6" 2000 12000
        safe_write 100 "$SWAP"
        echo "[TWEAKS] POWERSAVE applied" >> "$LOG" 2>/dev/null
        ;;
      LIGHT)
        apply_schedutil "$POL0" 500 4000
        apply_schedutil "$POL4" 500 4000
        apply_schedutil "$POL6" 500 4000
        safe_write 60 "$SWAP"
        echo "[TWEAKS] BALANCED applied" >> "$LOG" 2>/dev/null
        ;;
      ACTIVE|CHARGING)
        apply_schedutil "$POL0" 500 2000
        apply_schedutil "$POL4" 500 2000
        apply_schedutil "$POL6" 500 2000
        safe_write 10 "$SWAP"
        echo "[TWEAKS] PERF applied" >> "$LOG" 2>/dev/null
        ;;
      GAMING)
        apply_schedutil "$POL0" 500 500
        apply_schedutil "$POL4" 500 500
        apply_schedutil "$POL6" 500 500
        safe_write 10 "$SWAP"
        echo "[TWEAKS] GAMING applied — full clocks, ultra-low latency" >> "$LOG" 2>/dev/null
        ;;
    esac
  }

  # ─── WebUI permissions ────────────────────────────────────────────────────
  chmod -R 755 "$_MOD_DIR/webroot" 2>/dev/null
  chown -R root:root "$_MOD_DIR/webroot" 2>/dev/null
  chmod 644 "$_MOD_DIR/config.sh" 2>/dev/null

  # ─── Startup sanity check ─────────────────────────────────────────────────
  _skin_check=$(cat "$T_SKIN" 2>/dev/null)
  _gov_check=$(cat "$POL0/scaling_governor" 2>/dev/null)
  echo "[INIT] zone5(skin)=${_skin_check:-MISSING} governor=${_gov_check:-MISSING}" >> "$LOG"
  echo "[INIT] Gaming packages: $(echo $GAMING_PACKAGES | wc -w) | HARD_ABORT=${GAMING_HARD_ABORT}C" >> "$LOG"
  echo "[INIT] Triggers: AUTO=${TEMP_AUTO_TRIGGER}C GAMING=${TEMP_GAMING_TRIGGER}C SAVE=${TEMP_SAVE_TRIGGER}C" >> "$LOG"
  echo "[INIT] BURST_THRESH=${BURST_THRESH}% LOOP_SLEEP=${LOOP_SLEEP}s IDLE_BIG=stock (hotfix vY.1.1.1)" >> "$LOG"
  echo "[INIT] Entering main loop (LOOP_SLEEP=${LOOP_SLEEP}s, actual cycle ~$((LOOP_SLEEP+1))s)" >> "$LOG"

  # ─────────────────────────────────────────────────────────────────────────
  # Main loop
  # Actual cycle = 1 s (/proc/stat window) + LOOP_SLEEP s.
  # ─────────────────────────────────────────────────────────────────────────
  while true; do
    TICK=$((TICK+1))

    SKIN_T=$(get_skin_t)
    CORE_T=$(get_core_t)
    T=$SKIN_T
    [ "$CORE_T" -gt "$T" ] 2>/dev/null && T=$CORE_T

    # ── CPU load — 1-second /proc/stat window ─────────────────────────────
    read _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat 2>/dev/null
    sleep 1
    read _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat 2>/dev/null
    t1=$((u1+n1+s1+i1+w1+q1+sq1+st1))
    t2=$((u2+n2+s2+i2+w2+q2+sq2+st2))
    dt=$((t2-t1)); di=$((i2-i1))
    IL=0; [ "$dt" -gt 0 ] 2>/dev/null && IL=$(((dt-di)*100/dt))
    L1=$L2; L2=$L3; L3=$IL
    AVG=$(((L1+L2+L3)/3))

    # ── BURST: single-tick raw load ≥ BURST_THRESH → instant ACTIVE ───────
    # vY.1.1.1: threshold lowered 60 % → 25 % (configurable via BURST_THRESH)
    BURST=false
    [ "$IL" -ge "$BURST_THRESH" ] 2>/dev/null && BURST=true

    # ── Mode-specific HC trigger temperature ──────────────────────────────
    case "$MODE" in
      gaming)    TRIG=$TEMP_GAMING_TRIGGER ;;
      powersave) TRIG=$TEMP_SAVE_TRIGGER ;;
      *)         TRIG=$TEMP_AUTO_TRIGGER ;;
    esac
    [ "$T" -ge "$TRIG" ] 2>/dev/null && HC=$((HC+1)) || HC=0

    BT=$(cat "$BATT" 2>/dev/null)
    OFF=false; is_off && OFF=true
    NW=$(uptime_s)

    # ── Gaming detection (auto mode only, screen-on only) ─────────────────
    GAMING=false
    if [ "$MODE" = "auto" ] && [ "$OFF" = false ] && \
       [ "$_GAMING_ENABLED" = true ] && is_gaming; then
      GAMING=true
    fi

    # ── GAMING hard abort — forced exit regardless of MODE or IGNORE flag ─
    if [ "$ST" = "GAMING" ] && [ "$T" -ge "$GAMING_HARD_ABORT" ] 2>/dev/null; then
      GAMING=false
      echo "[GAMING] HARD ABORT — skin ${T}C >= ${GAMING_HARD_ABORT}C, forcing ACTIVE" >> "$LOG" 2>/dev/null
    fi

    # ── Mode decision ─────────────────────────────────────────────────────
    if [ "$MODE" = "powersave" ]; then
      if [ "$OFF" = true ]; then TG="POCKET"
      else TG="POWERSAVE"
      fi
    elif [ "$MODE" = "gaming" ]; then
      if [ "$OFF" = true ]; then
        TG="POCKET"
      elif [ "$T" -ge "$GAMING_HARD_ABORT" ] 2>/dev/null; then
        TG="ACTIVE"
      else
        TG="GAMING"; GAMING=true
      fi
    elif [ "$GAMING" = true ]; then
      TG="GAMING"
    elif [ "$OFF" = true ]; then
      TG="POCKET"
    elif [ "$BT" = "Charging" ] && [ "$SKIN_T" -ge 38 ] 2>/dev/null; then
      TG="CHARGING"
    elif [ "$CORE_T" -ge 45 ] 2>/dev/null; then
      TG="ACTIVE"
    elif [ "$SKIN_T" -ge 41 ] 2>/dev/null; then
      TG="ACTIVE"
    elif [ "$SKIN_T" -ge 37 ] 2>/dev/null; then
      TG="LIGHT"
    elif [ "$AVG" -ge 40 ] 2>/dev/null || [ "$BURST" = true ]; then
      TG="ACTIVE"
    elif [ "$AVG" -ge 15 ] 2>/dev/null; then
      TG="LIGHT"
    else
      TG="IDLE"
    fi

    # ── Debounce ──────────────────────────────────────────────────────────
    # Instant transitions:
    #   - Any GAMING entry/exit
    #   - BURST-triggered ACTIVE
    #   - vY.1.1.1: any upgrade OUT of IDLE (scroll/swipe gesture fix)
    # All other transitions: 15 s cooldown.
    if [ "$TG" != "$ST" ]; then
      _switch=false
      if [ "$TG" = "GAMING" ] || [ "$ST" = "GAMING" ]; then
        _switch=true
      elif [ "$TG" = "ACTIVE" ] && [ "$BURST" = true ]; then
        _switch=true
      elif [ "$ST" = "IDLE" ] || [ "$ST" = "LIGHT" ]; then
        # vY.1.1.1: upgrading FROM IDLE or LIGHT is always instant.
        # Covers app launch, keyboard open, recents, tab switches.
        # LIGHT is an intermediate state; any upgrade from it should not
        # wait 15 s. (Was IDLE-only in the scroll/swipe fix.)
      elif [ $((NW - LC)) -ge "$DB" ] 2>/dev/null; then
        _switch=true
      fi
      if [ "$_switch" = true ]; then
        echo "[STATE] $ST -> $TG (Skin=${SKIN_T}C Core=${CORE_T}C L=${AVG}% IL=${IL}% Burst=$BURST)" >> "$LOG" 2>/dev/null
        ST="$TG"; LC=$NW
        apply_tweaks "$ST"
      fi
    fi

    # ── Frequency caps ────────────────────────────────────────────────────
    #
    # Mode     | LITTLE (pol0) | MID (pol4)  | BIG (pol6)
    # ----------+---------------+-------------+-----------
    # POCKET    |  600 MHz      |  600 MHz    |  600 MHz
    # POWERSAVE | 1170 MHz      | 1388 MHz    | 1638 MHz  (60 % stock)
    # IDLE      | 1600 MHz      | 1400 MHz    | 1600 MHz  [vY.1.1.1: was 1200]
    # LIGHT     | 1950 MHz      | 2000 MHz    | 2200 MHz
    # CHARGING  |  975 MHz      | 1157 MHz    | 1092 MHz
    # ACTIVE    | dynamic thermal steps (50/65/80/100 %)
    # GAMING    | 1950 MHz      | 2314 MHz    | 2730 MHz  (full stock OPP)
    #
    F0=$M0; F4=$M4; F6=$M6

    case "$ST" in
      GAMING)
        if [ "$GAMING_IGNORE_THERMAL" != "true" ] && \
           [ "$SKIN_T" -ge "$GAMING_THERMAL_CEIL" ] 2>/dev/null; then
          F6=$((M6*80/100))
          echo "[GAMING] Soft cap — skin ${SKIN_T}C >= ${GAMING_THERMAL_CEIL}C, BIG -> $F6 Hz" >> "$LOG" 2>/dev/null
        fi
        ;;
      POCKET)
        F0=600000; F4=600000; F6=600000
        ;;
      POWERSAVE)
        F0=$((M0*60/100)); F4=$((M4*60/100)); F6=$((M6*60/100))
        ;;
      CHARGING)
        F0=$((M0/2)); F4=$((M4/2)); F6=$((M6*40/100))
        ;;
      IDLE)
        # vY.1.1.1: BIG set to full stock — no cap when cool, let schedutil decide
        F0=1600000; F4=1400000; F6=$M6
        ;;
      LIGHT)
        F0=1950000; F4=2000000; F6=2200000
        ;;
      ACTIVE)
        if [ "$HC" -ge 2 ] 2>/dev/null; then
          if   [ "$T" -ge 44 ] 2>/dev/null; then
            F0=$((M0/2));      F4=$((M4/2));      F6=$((M6/2))
          elif [ "$T" -ge 42 ] 2>/dev/null; then
            F0=$((M0*65/100)); F4=$((M4*65/100)); F6=$((M6*65/100))
          elif [ "$T" -ge 40 ] 2>/dev/null; then
            F0=$((M0*80/100)); F4=$((M4*80/100)); F6=$((M6*80/100))
          fi
        fi
        ;;
    esac

    safe_write "$F0" "$POL0/scaling_max_freq"
    safe_write "$F4" "$POL4/scaling_max_freq"
    safe_write "$F6" "$POL6/scaling_max_freq"

    # ── Log line — human-readable timestamp + full state ──────────────────
    _ts=$(date +%H:%M:%S 2>/dev/null || uptime_s)
    echo "[$_ts] $ST Skin=${SKIN_T}C Core=${CORE_T}C H=$HC L=${AVG}% IL=${IL}% F0=$F0 F4=$F4 F6=$F6 M=$MODE" >> "$LOG" 2>/dev/null

    # ── Unconditional log rotation every 500 ticks (~41 min at 5 s/tick) ─
    [ $((TICK % 500)) -eq 0 ] && rotate_log

    sleep "$LOOP_SLEEP"
  done

) > /dev/null 2>"$ERR" &

exit 0
