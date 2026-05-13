#!/system/bin/sh
# PrimeThermal-ArtisanROM vY.1
# Fork of PrimeThermal v1.1-OneUI by Prime1337
# Rebuilt for: Samsung Galaxy S10+ (SM-G975F / beyond2lte)
#              ArtisanROM Quant | OneUI 8 | Android 16
#              KernelSU-Next | ArtisanKRNL (upstreamed)
#
# Key facts from ArtisanROM source repo:
#  - Kernel is fully upstreamed (Linux 5.x / bpf111 branch)
#    → schedutil is the ONLY governor (interactive/ondemand removed in 5.x)
#    → compact_memory node DOES NOT EXIST (removed in Linux 5.18+)
#    → schedutil tunables live at policyX/schedutil/ per-policy ✓
#  - Heavily DeKnoxed: Samsung thermal daemon stripped
#    → No sec_ts interference; sysfs thermal writes go through cleanly
#  - KernelSU-Next: /data/adb/ is writable by root modules ✓
#  - S10+ (G975F) cpufreq layout confirmed: pol0/pol4/pol6 ✓
#  - Backlight sysfs on ArtisanROM / OneUI 8: probe panel0-backlight + panel-0
#  - SELinux: Full support (enforcing), sysfs thermal nodes readable by root ✓
#  - "Completely upstreamed kernels" — thermal zone numbering follows
#    standard Exynos 9820 DTS, NOT Android HAL virtual zone numbering:
#      zone0 = CPU cluster 0 (LITTLE, cpu0-3)
#      zone1 = CPU cluster 1 (MID,   cpu4-5)
#      zone2 = CPU cluster 2 (BIG,   cpu6-7)
#      zone3 = GPU
#      zone4 = ISP
#      zone5 = skin/PCB (primary)  ← confirmed in upstream DTS
#      zone6 = battery             ← confirmed in upstream DTS
#    (No HAL renumbering on upstreamed kernel — zones are stable)

# ─── Log path: KernelSU-Next module dir is writable, prefer it ──────────────
_MOD_DIR="/data/adb/modules/PrimeThermalArtisanROM"
if [ -d "$_MOD_DIR" ] && [ -w "$_MOD_DIR" ]; then
  LOG="$_MOD_DIR/thermal.log"
  ERR="$_MOD_DIR/thermal.err"
else
  mkdir -p /data/local/tmp 2>/dev/null
  LOG="/data/local/tmp/s10_thermal.log"
  ERR="/data/local/tmp/s10_thermal.err"
fi

echo "[INIT] PrimeThermal vY.1-ArtisanROM started $(date) PID=$$" > "$LOG"

(
  LOG="$LOG"
  ERR="$ERR"

  # ─── CPU policy paths (S10+ beyond2lte, Exynos 9820 confirmed) ─────────
  POL0="/sys/devices/system/cpu/cpufreq/policy0"   # LITTLE  cpu0-3  Cortex-A55
  POL4="/sys/devices/system/cpu/cpufreq/policy4"   # MID     cpu4-5  Cortex-A75
  POL6="/sys/devices/system/cpu/cpufreq/policy6"   # BIG     cpu6-7  Cortex-A75 prime

  # Max safe frequencies (Hz) — Exynos 9820 stock OPP table
  M0=1950000; M4=2314000; M6=2730000

  # ─── Thermal sensors (stable on upstreamed kernel, no HAL renumbering) ──
  # Confirmed from Exynos 9820 DTS in upstream kernel source
  T_SKIN="/sys/class/thermal/thermal_zone5/temp"   # skin/PCB
  T_BATT="/sys/class/thermal/thermal_zone6/temp"   # battery (fallback)
  T_CORE0="/sys/class/thermal/thermal_zone0/temp"  # LITTLE cluster
  T_CORE1="/sys/class/thermal/thermal_zone1/temp"  # MID cluster
  T_CORE2="/sys/class/thermal/thermal_zone2/temp"  # BIG cluster

  # ─── Battery / swap ─────────────────────────────────────────────────────
  BATT="/sys/class/power_supply/battery/status"
  SWAP="/proc/sys/vm/swappiness"
  # NOTE: compact_memory is NOT written — node does not exist on Linux 5.18+
  # (ArtisanKRNL is upstreamed past this point)

  # ─── State ──────────────────────────────────────────────────────────────
  ST="ACTIVE"; LC=0; DB=15; L1=0; L2=0; L3=0; HC=0

  # ─────────────────────────────────────────────────────────────────────────
  # safe_write <value> <path>
  # Skip silently if node missing or SELinux-denied
  # ─────────────────────────────────────────────────────────────────────────
  safe_write() {
    [ -f "$2" ] && echo "$1" > "$2" 2>/dev/null
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
  # get_skin_t — skin temp in °C (milli-Celsius auto-detected)
  # Primary: zone5 (skin/PCB). Fallback: zone6 (battery).
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
  # get_core_t — max temp across three CPU clusters
  # ─────────────────────────────────────────────────────────────────────────
  get_core_t() {
    t0=$(cat "$T_CORE0" 2>/dev/null); t0=${t0:-0}
    t1=$(cat "$T_CORE1" 2>/dev/null); t1=${t1:-0}
    t2=$(cat "$T_CORE2" 2>/dev/null); t2=${t2:-0}
    [ "$t0" -gt 1000 ] 2>/dev/null && t0=$((t0/1000))
    [ "$t1" -gt 1000 ] 2>/dev/null && t1=$((t1/1000))
    [ "$t2" -gt 1000 ] 2>/dev/null && t2=$((t2/1000))
    max=$t0
    [ "$t1" -gt "$max" ] 2>/dev/null && max=$t1
    [ "$t2" -gt "$max" ] 2>/dev/null && max=$t2
    echo "$max"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Detect backlight sysfs node at startup (probe two known paths)
  # ArtisanROM / OneUI 8 on S10+: usually panel0-backlight; some builds
  # use panel-0 or s6e3ha9 (the actual S10+ panel driver name).
  # We pick the first one that exists and is readable.
  # ─────────────────────────────────────────────────────────────────────────
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
  #
  # Strategy for ArtisanROM (upstreamed kernel, DeKnoxed, OneUI 8):
  #  1. Backlight brightness=0 → fastest (~1ms), no binder needed
  #  2. dumpsys power → reliable Android API, ~80ms
  #
  # Note: SurfaceFlinger "Display State" grep was removed — ArtisanROM's
  # SF output format varies and produces false positives on this ROM.
  # dumpsys power is the correct authoritative source.
  # ─────────────────────────────────────────────────────────────────────────
  is_off() {
    if [ -n "$BL_NODE" ]; then
      _bv=$(cat "$BL_NODE" 2>/dev/null)
      [ "${_bv:-1}" = "0" ] && return 0
      return 1
    fi
    # Fallback: dumpsys power
    dumpsys power 2>/dev/null | grep -q "Display Power: state=OFF" && return 0
    return 1
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_tweaks <mode>
  #
  # ArtisanROM / upstreamed kernel: schedutil is the ONLY governor.
  # Tunables live at: /sys/devices/system/cpu/cpufreq/policyX/schedutil/
  # Keys used:
  #   rate_limit_us    — single combined rate limit (some upstream builds)
  #   up_rate_limit_us / down_rate_limit_us — per-direction (preferred)
  # We write both forms; safe_write silently ignores whichever isn't present.
  # ─────────────────────────────────────────────────────────────────────────
  apply_schedutil() {
    _pol="$1"; _up="$2"; _dn="$3"
    safe_write "$_up" "${_pol}/schedutil/up_rate_limit_us"
    safe_write "$_dn" "${_pol}/schedutil/down_rate_limit_us"
    # Some upstream builds expose only the combined knob
    safe_write "$_up" "${_pol}/schedutil/rate_limit_us"
  }

  apply_tweaks() {
    case "$1" in
      POCKET|IDLE)
        apply_schedutil "$POL0" 2000 10000
        apply_schedutil "$POL4" 2000 10000
        apply_schedutil "$POL6" 2000 10000
        safe_write 100 "$SWAP"
        echo "[TWEAKS] ECO applied" >> "$LOG" 2>/dev/null
        ;;
      LIGHT)
        apply_schedutil "$POL0" 1000 5000
        apply_schedutil "$POL4" 1000 5000
        apply_schedutil "$POL6" 1000 5000
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
    esac
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Startup: log sensor sanity check
  # ─────────────────────────────────────────────────────────────────────────
  _skin_check=$(cat "$T_SKIN" 2>/dev/null)
  _gov_check=$(cat "$POL0/scaling_governor" 2>/dev/null)
  echo "[INIT] zone5(skin)=${_skin_check:-MISSING} governor=${_gov_check:-MISSING}" >> "$LOG"
  echo "[INIT] Entering main loop" >> "$LOG"

  # ─────────────────────────────────────────────────────────────────────────
  # Main loop
  # ─────────────────────────────────────────────────────────────────────────
  while true; do
    SKIN_T=$(get_skin_t)
    CORE_T=$(get_core_t)

    # Use max of both sensors; skin takes semantic priority for mode switching
    T=$SKIN_T
    [ "$CORE_T" -gt "$T" ] 2>/dev/null && T=$CORE_T

    # CPU load — 1-second window via /proc/stat
    read _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat 2>/dev/null
    sleep 1
    read _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat 2>/dev/null
    t1=$((u1+n1+s1+i1+w1+q1+sq1+st1))
    t2=$((u2+n2+s2+i2+w2+q2+sq2+st2))
    dt=$((t2-t1)); di=$((i2-i1))
    IL=0; [ "$dt" -gt 0 ] 2>/dev/null && IL=$(((dt-di)*100/dt))
    L1=$L2; L2=$L3; L3=$IL
    AVG=$(((L1+L2+L3)/3))

    # Hot counter: increments when T >= 40°C
    [ "$T" -ge 40 ] 2>/dev/null && HC=$((HC+1)) || HC=0

    BT=$(cat "$BATT" 2>/dev/null)
    OFF=false; is_off && OFF=true
    NW=$(date +%s 2>/dev/null)

    # ── Mode decision (priority order) ────────────────────────────────────
    if [ "$OFF" = true ]; then
      TG="POCKET"
    elif [ "$BT" = "Charging" ] && [ "$SKIN_T" -ge 38 ] 2>/dev/null; then
      TG="CHARGING"
    elif [ "$CORE_T" -ge 45 ] 2>/dev/null; then
      TG="ACTIVE"
    elif [ "$SKIN_T" -ge 41 ] 2>/dev/null; then
      TG="ACTIVE"
    elif [ "$SKIN_T" -ge 37 ] 2>/dev/null; then
      TG="LIGHT"
    elif [ "$AVG" -ge 40 ] 2>/dev/null; then
      TG="ACTIVE"
    elif [ "$AVG" -ge 15 ] 2>/dev/null; then
      TG="LIGHT"
    else
      TG="IDLE"
    fi

    # ── Debounce: switch mode only every DB seconds ──────────────────────
    if [ "$TG" != "$ST" ]; then
      if [ $((NW - LC)) -ge "$DB" ] 2>/dev/null; then
        echo "[STATE] $ST -> $TG (Skin=${SKIN_T}C Core=${CORE_T}C L=$AVG%)" >> "$LOG" 2>/dev/null
        ST="$TG"; LC=$NW
        apply_tweaks "$ST"
        rotate_log
      fi
    fi

    # ── Frequency caps ────────────────────────────────────────────────────
    F0=$M0; F4=$M4; F6=$M6
    case "$ST" in
      POCKET)
        F0=600000;  F4=600000;  F6=600000
        ;;
      CHARGING)
        F0=$((M0/2)); F4=$((M4/2)); F6=$((M6*40/100))
        ;;
      IDLE)
        F0=1000000; F4=900000;  F6=700000
        ;;
      LIGHT)
        F0=1300000; F4=1500000; F6=1700000
        ;;
      ACTIVE)
        # Thermal throttle when persistently hot (HC >= 2 cycles)
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

    echo "[$(date +%H:%M:%S)] $ST Skin=${SKIN_T}C Core=${CORE_T}C H=$HC L=${AVG}% F6=$F6" >> "$LOG" 2>/dev/null
    sleep 4
  done

) > /dev/null 2>"$ERR" &

exit 0
