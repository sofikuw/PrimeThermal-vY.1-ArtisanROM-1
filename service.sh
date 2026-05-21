#!/system/bin/sh
# PrimeThermal-ArtisanROM vY.1.2 — Thermal + Gaming Enhancement
#
# ─── Upstream & Authorship ───────────────────────────────────────────────────
#
# Original project: PrimeThermal by igoraotel-a11y (Prime1337)
#   https://github.com/igoraotel-a11y/PrimeThermal
#   Adaptive thermal & CPU manager for Samsung Galaxy S10 (Exynos 9820).
#   All core architecture — state machine, thermal sensors, schedutil tuning,
#   frequency caps, log rotation — originates from this upstream.
#
# ArtisanROM fork: sofikuw
#   https://github.com/sofikuw/PrimeThermal-vY.1-ArtisanROM-1
#   Rebuilt for SM-G975F / ArtisanROM Quant / KernelSU-Next / ArtisanKRNL.
#   Added GAMING mode, BURST detection, WebUI scaffolding, hard abort,
#   per-mode HC triggers, vY.1.1.x responsiveness hotfixes.
#   sofikuw is also a credited collaborator on the upstream v1.2 release.
#
# ─── Third-party credits ────────────────────────────────────────────────────
#
# Encore Tweaks by Rem01Gaming — Apache License 2.0
#   https://github.com/Rem01Gaming/encore
#   gamelist.txt (530+ game package names) incorporated into GAMING_PACKAGES.
#   Only the package-name data was used; no Encore code runs here.
#
# Gaming-X Magisk Module by JordanTweaks — GNU GPL v3.0
#   https://github.com/JordanTweaks/Gaming-X-Magisk-Module
#   SurfaceFlinger debug.sf.* property pattern (apply_sf_tweaks) and the
#   Android Game Manager API call pattern (apply_game_cmd) were adapted
#   from Gaming-X's service.sh. No code was copied verbatim; the logic was
#   re-implemented to fit PrimeThermal's state-machine structure.
#
# SpeedCool Magisk Module by Llucs
#   https://github.com/Llucs/SpeedCool-Magisk-Module
#   Bootloop recovery concept (boot_ok flag + forced safe mode on startup)
#   was inspired by SpeedCool's "Bootloop Recovery System" design.
#
# ─── Target environment ──────────────────────────────────────────────────────
# Device : Samsung Galaxy S10 series (Exynos 9820)
#            SM-G970F / beyond0lte  (S10e — 6 GB)
#            SM-G973F / beyond1lte  (S10  — 6/8 GB)
#            SM-G975F / beyond2lte  (S10+ — 8/12 GB)
# ROM    : ArtisanROM Quant | OneUI 8 | Android 16
# Root   : KernelSU-Next
# Kernel : ArtisanKRNL (upstreamed Linux 5.x)
# Note   : All three share identical Exynos 9820 cpufreq topology and
#          thermal zone layout — the same daemon binary works on all.
#
# vY.1.2 improvements over vY.1.1.1:
#
#  * Encore gamelist — 530+ game packages merged into GAMING_PACKAGES.
#
#  * scaling_min_freq GAMING floors — locks a configurable % of each
#    cluster's max OPP as a minimum during GAMING state. Prevents
#    schedutil from drooping to low OPPs between frames, eliminating
#    the spike-stutter pattern on Exynos 9820.
#    Resets to cpuinfo_min_freq in all non-GAMING states.
#    Controlled by GAMING_MIN_FLOOR_PCT (default 50 %).
#
#  * SurfaceFlinger latency tweaks (Gaming-X inspired) — on GAMING
#    entry writes debug.sf.disable_backpressure, latch_unsignaled,
#    and early_phase_offset_ns; resets on exit.
#    Toggle: ENABLE_SF_TWEAKS (default true).
#
#  * I/O scheduler tuning — GAMING/ACTIVE: deadline + nr_requests 512.
#    IDLE/POWERSAVE: cfq + nr_requests 128.
#    Toggle: ENABLE_IO_TUNING (default true).
#
#  * sched_boost (Samsung EAS) — writes 1 to
#    /proc/sys/kernel/sched_boost on GAMING, 0 otherwise.
#    safe_write-guarded; skipped silently if node absent.
#    Toggle: ENABLE_SCHED_BOOST (default true).
#
#  * Android Game Manager API (Gaming-X inspired) — detects
#    foreground package on GAMING entry and calls:
#      cmd game set --mode 2 <pkg>   (performance)
#    Resets to mode 0 on exit. Requires Android 12+.
#    Toggle: ENABLE_GAME_CMD (default true).
#
#  * vm.dirty_ratio / vm.vfs_cache_pressure per state — larger dirty
#    window and lower cache pressure in GAMING; tighter in IDLE.
#
#  * swappiness 1 (not 10) in GAMING — S10 series has 6–12 GB RAM;
#    near-zero swappiness keeps game data fully resident on all variants.
#
#  * Bootloop safety guard (SpeedCool inspired) — checks for boot_ok
#    flag on startup. If absent, forces POWERSAVE for 24 ticks (~120 s)
#    then auto-restores configured MODE.
#
#  * BURST_THRESH exported to config.sh (was hardcoded).
#
#  * WebUI (MMRL/KSU-Next) — live log, state, mode toggle, gamelist.
#
# Kernel facts (ArtisanROM Quant / ArtisanKRNL upstreamed Linux 5.x):
#  - schedutil is the ONLY governor (interactive/ondemand removed).
#  - compact_memory node absent (removed in Linux 5.18+).
#  - cpufreq: pol0=LITTLE cpu0-3, pol4=MID cpu4-5, pol6=BIG cpu6-7.
#  - Thermal zones: zone0-2=clusters, zone5=skin/PCB, zone6=battery.
#  - Samsung thermal daemon stripped (DeKnoxed) — sysfs uncontested.
#  - SELinux Enforcing — all writes via root sysfs.
#  - No KGSL (Exynos), no cpu_boost (Qualcomm).

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
GAMING_MIN_FLOOR_PCT=50
LOOP_SLEEP=4
ENABLE_LOG=true
MODE=auto
TEMP_AUTO_TRIGGER=42
TEMP_GAMING_TRIGGER=45
TEMP_SAVE_TRIGGER=38
BURST_THRESH=25
ENABLE_SF_TWEAKS=true
ENABLE_IO_TUNING=true
ENABLE_SCHED_BOOST=true
ENABLE_GAME_CMD=true

_CFG="$_MOD_DIR/config.sh"
[ -f "$_CFG" ] && . "$_CFG"

# ─── Log control ─────────────────────────────────────────────────────────────
[ "$ENABLE_LOG" = "true" ] || exec >/dev/null 2>/dev/null

# ─── Device detection ────────────────────────────────────────────────────────
_DEVICE="$(getprop ro.product.device 2>/dev/null)"
case "$_DEVICE" in
  beyond0lte) _MODEL="SM-G970F (S10e)" ;;
  beyond1lte) _MODEL="SM-G973F (S10)"  ;;
  beyond2lte) _MODEL="SM-G975F (S10+)" ;;
  *)          _MODEL="$_DEVICE (unrecognised — proceeding anyway)" ;;
esac

echo "[INIT] PrimeThermal vY.1.2-ArtisanROM started $(date) PID=$$" > "$LOG"
echo "[INIT] Device: ${_MODEL}" >> "$LOG"
echo "[INIT] MODE=${MODE} BURST=${BURST_THRESH} SF=${ENABLE_SF_TWEAKS} IO=${ENABLE_IO_TUNING} BOOST=${ENABLE_SCHED_BOOST} GCMD=${ENABLE_GAME_CMD}" >> "$LOG"
echo "[INIT] MIN_FLOOR=${GAMING_MIN_FLOOR_PCT}% HARD_ABORT=${GAMING_HARD_ABORT}C" >> "$LOG"

# ─── Cover image symlink ─────────────────────────────────────────────────────
if [ -n "$COVER_IMAGE" ] && [ -f "$_MOD_DIR/$COVER_IMAGE" ]; then
  mkdir -p "$_MOD_DIR/webroot" 2>/dev/null
  ln -sf "$_MOD_DIR/$COVER_IMAGE" "$_MOD_DIR/webroot/cover.png" 2>/dev/null
  [ "$COVER_IMAGE" != "cover.png" ] && \
    ln -sf "$_MOD_DIR/$COVER_IMAGE" "$_MOD_DIR/cover.png" 2>/dev/null
fi

# ─── Bootloop safety guard ───────────────────────────────────────────────────
# boot_ok is absent when the previous boot crashed before a full loop tick.
# Force POWERSAVE for 24 ticks (~120 s), then restore the user's MODE.
_BOOT_OK="$_MOD_DIR/boot_ok"
_SAFE_BOOT=false
_ORIG_MODE="$MODE"
if [ ! -f "$_BOOT_OK" ]; then
  echo "[SAFETY] boot_ok absent — forcing POWERSAVE for 120 s" >> "$LOG"
  _SAFE_BOOT=true
  MODE=powersave
fi
rm -f "$_BOOT_OK" 2>/dev/null

# ─── Signal handling ─────────────────────────────────────────────────────────
_BG_PID=""
trap '
  touch "$_BOOT_OK" 2>/dev/null
  [ -n "$_BG_PID" ] && kill "$_BG_PID" 2>/dev/null
  exit 0
' TERM INT

(
  LOG="$LOG"
  ERR="$ERR"

  # ─── CPU policy paths ─────────────────────────────────────────────────────
  POL0="/sys/devices/system/cpu/cpufreq/policy0"   # LITTLE  cpu0-3  Cortex-A55
  POL4="/sys/devices/system/cpu/cpufreq/policy4"   # MID     cpu4-5  Cortex-A75
  POL6="/sys/devices/system/cpu/cpufreq/policy6"   # BIG     cpu6-7  Cortex-A75 prime

  # Max stock OPP frequencies (Hz) — Exynos 9820
  M0=1950000; M4=2314000; M6=2730000
  # Stock minimum OPP frequencies (Hz)
  MIN0=300000; MIN4=500000; MIN6=741000

  # ─── Thermal sensors ──────────────────────────────────────────────────────
  T_SKIN="/sys/class/thermal/thermal_zone5/temp"
  T_BATT="/sys/class/thermal/thermal_zone6/temp"
  T_CORE0="/sys/class/thermal/thermal_zone0/temp"
  T_CORE1="/sys/class/thermal/thermal_zone1/temp"
  T_CORE2="/sys/class/thermal/thermal_zone2/temp"

  # ─── System nodes ─────────────────────────────────────────────────────────
  BATT="/sys/class/power_supply/battery/status"
  SWAP="/proc/sys/vm/swappiness"
  VM_DIRTY="/proc/sys/vm/dirty_ratio"
  VM_DIRTY_BG="/proc/sys/vm/dirty_background_ratio"
  VM_CACHE="/proc/sys/vm/vfs_cache_pressure"

  # ─── State ────────────────────────────────────────────────────────────────
  ST="ACTIVE"; LC=0; DB=15; L1=0; L2=0; L3=0; HC=0; TICK=0
  _LAST_GAME_PKG=""
  _GAMING_ENABLED=false
  [ -n "$GAMING_PACKAGES" ] && _GAMING_ENABLED=true

  # ─────────────────────────────────────────────────────────────────────────
  safe_write() { [ -f "$2" ] && echo "$1" > "$2" 2>/dev/null; }

  uptime_s() {
    read _up _idle < /proc/uptime 2>/dev/null
    echo "${_up%%.*}"
  }

  rotate_log() {
    [ -f "$LOG" ] || return
    lines=$(wc -l < "$LOG" 2>/dev/null | tr -d ' ')
    if [ "$lines" -gt 1000 ] 2>/dev/null; then
      tail -n 1000 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG" 2>/dev/null
      echo "[SYS] Log rotated" >> "$LOG" 2>/dev/null
    fi
  }

  read_temp() {
    v=$(cat "$1" 2>/dev/null); v=${v:-0}
    [ "$v" -gt 1000 ] 2>/dev/null && v=$((v/1000))
    echo "$v"
  }

  get_skin_t() {
    v=$(cat "$T_SKIN" 2>/dev/null)
    [ -z "$v" ] || [ "$v" = "0" ] && v=$(cat "$T_BATT" 2>/dev/null)
    v=${v:-0}
    [ "$v" -gt 1000 ] 2>/dev/null && v=$((v/1000))
    echo "$v"
  }

  get_core_t() {
    t0=$(read_temp "$T_CORE0"); t1=$(read_temp "$T_CORE1"); t2=$(read_temp "$T_CORE2")
    max=$t0
    [ "$t1" -gt "$max" ] 2>/dev/null && max=$t1
    [ "$t2" -gt "$max" ] 2>/dev/null && max=$t2
    echo "$max"
  }

  # ─── Backlight node detection ─────────────────────────────────────────────
  BL_NODE=""
  for _bl in /sys/class/backlight/panel0-backlight/brightness \
             /sys/class/backlight/panel-0/brightness \
             /sys/class/backlight/s6e3ha9/brightness \
             /sys/class/backlight/s6e3hc2/brightness; do
    [ -r "$_bl" ] && BL_NODE="$_bl" && break
  done
  echo "[INIT] Backlight: ${BL_NODE:-NOT FOUND}" >> "$LOG"

  is_off() {
    if [ -n "$BL_NODE" ]; then
      _bv=$(cat "$BL_NODE" 2>/dev/null)
      [ "${_bv:-1}" = "0" ] && return 0; return 1
    fi
    dumpsys power 2>/dev/null | grep -q "Display Power: state=OFF" && return 0
    return 1
  }

  is_gaming() {
    _fg=$(dumpsys activity recents 2>/dev/null \
          | grep -m1 "Recent #0" \
          | grep -oE "[a-z][a-zA-Z0-9_]*(\.[a-zA-Z0-9_]+){2,}" \
          | head -1)
    [ -z "$_fg" ] && return 1
    for _pkg in $GAMING_PACKAGES; do [ "$_fg" = "$_pkg" ] && return 0; done
    return 1
  }

  get_fg_pkg() {
    dumpsys activity recents 2>/dev/null \
      | grep -m1 "Recent #0" \
      | grep -oE "[a-z][a-zA-Z0-9_]*(\.[a-zA-Z0-9_]+){2,}" \
      | head -1
  }

  apply_schedutil() {
    safe_write "$2" "${1}/schedutil/up_rate_limit_us"
    safe_write "$3" "${1}/schedutil/down_rate_limit_us"
    safe_write "$2" "${1}/schedutil/rate_limit_us"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_io_sched <gaming|active|idle>
  # ─────────────────────────────────────────────────────────────────────────
  apply_io_sched() {
    for _bdev in /sys/block/*/queue/scheduler; do
      [ -f "$_bdev" ] || continue
      _qd="${_bdev%scheduler}nr_requests"
      case "$1" in
        gaming|active)
          echo "deadline" > "$_bdev" 2>/dev/null || \
          echo "noop"     > "$_bdev" 2>/dev/null || \
          echo "none"     > "$_bdev" 2>/dev/null
          safe_write 512 "$_qd"
          ;;
        idle)
          echo "cfq" > "$_bdev" 2>/dev/null || \
          echo "bfq" > "$_bdev" 2>/dev/null
          safe_write 128 "$_qd"
          ;;
      esac
    done
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_sf_tweaks <gaming|normal>
  # ─────────────────────────────────────────────────────────────────────────
  apply_sf_tweaks() {
    if [ "$1" = "gaming" ]; then
      setprop debug.sf.disable_backpressure   1       2>/dev/null
      setprop debug.sf.latch_unsignaled       1       2>/dev/null
      setprop debug.sf.early_phase_offset_ns  500000  2>/dev/null
      setprop debug.sf.early_app_phase_offset_ns 500000 2>/dev/null
      setprop debug.sf.recomputecrop          0       2>/dev/null
      setprop debug.egl.hw                    1       2>/dev/null
      echo "[SF] Gaming tweaks applied" >> "$LOG" 2>/dev/null
    else
      setprop debug.sf.disable_backpressure   0       2>/dev/null
      setprop debug.sf.latch_unsignaled       0       2>/dev/null
      setprop debug.sf.early_phase_offset_ns  0       2>/dev/null
      setprop debug.sf.early_app_phase_offset_ns 0    2>/dev/null
      setprop debug.sf.recomputecrop          0       2>/dev/null
      setprop debug.egl.hw                    1       2>/dev/null
      echo "[SF] Tweaks reset" >> "$LOG" 2>/dev/null
    fi
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_game_cmd <enter|exit>
  # ─────────────────────────────────────────────────────────────────────────
  apply_game_cmd() {
    if [ "$1" = "enter" ]; then
      _pkg=$(get_fg_pkg)
      if [ -n "$_pkg" ]; then
        cmd game set --mode 2 "$_pkg" 2>/dev/null
        _LAST_GAME_PKG="$_pkg"
        echo "[GCMD] Perf mode 2: $_pkg" >> "$LOG" 2>/dev/null
      fi
    else
      if [ -n "$_LAST_GAME_PKG" ]; then
        cmd game set --mode 0 "$_LAST_GAME_PKG" 2>/dev/null
        echo "[GCMD] Reset mode 0: $_LAST_GAME_PKG" >> "$LOG" 2>/dev/null
        _LAST_GAME_PKG=""
      fi
    fi
  }

  # ─────────────────────────────────────────────────────────────────────────
  # apply_tweaks <state>
  #
  # schedutil:  up=500 µs on all modes; dn varies by state.
  #   POCKET/IDLE    : up=500  dn=4000 µs
  #   POWERSAVE      : up=2000 dn=12000 µs
  #   LIGHT          : up=500  dn=4000 µs
  #   ACTIVE/CHARGING: up=500  dn=2000 µs
  #   GAMING         : up=500  dn=500 µs
  # ─────────────────────────────────────────────────────────────────────────
  apply_tweaks() {
    case "$1" in
      POCKET|IDLE)
        apply_schedutil "$POL0" 500 4000
        apply_schedutil "$POL4" 500 4000
        apply_schedutil "$POL6" 500 4000
        safe_write 100 "$SWAP"; safe_write 20 "$VM_DIRTY"
        safe_write 10 "$VM_DIRTY_BG"; safe_write 100 "$VM_CACHE"
        [ "$ENABLE_SCHED_BOOST" = "true" ] && safe_write 0 /proc/sys/kernel/sched_boost
        [ "$ENABLE_IO_TUNING"   = "true" ] && apply_io_sched idle
        [ "$ENABLE_SF_TWEAKS"   = "true" ] && apply_sf_tweaks normal
        echo "[TWEAKS] ECO" >> "$LOG" 2>/dev/null
        ;;
      POWERSAVE)
        apply_schedutil "$POL0" 2000 12000
        apply_schedutil "$POL4" 2000 12000
        apply_schedutil "$POL6" 2000 12000
        safe_write 100 "$SWAP"; safe_write 15 "$VM_DIRTY"
        safe_write 5 "$VM_DIRTY_BG"; safe_write 100 "$VM_CACHE"
        [ "$ENABLE_SCHED_BOOST" = "true" ] && safe_write 0 /proc/sys/kernel/sched_boost
        [ "$ENABLE_IO_TUNING"   = "true" ] && apply_io_sched idle
        [ "$ENABLE_SF_TWEAKS"   = "true" ] && apply_sf_tweaks normal
        echo "[TWEAKS] POWERSAVE" >> "$LOG" 2>/dev/null
        ;;
      LIGHT)
        apply_schedutil "$POL0" 500 4000
        apply_schedutil "$POL4" 500 4000
        apply_schedutil "$POL6" 500 4000
        safe_write 60 "$SWAP"; safe_write 20 "$VM_DIRTY"
        safe_write 10 "$VM_DIRTY_BG"; safe_write 80 "$VM_CACHE"
        [ "$ENABLE_SCHED_BOOST" = "true" ] && safe_write 0 /proc/sys/kernel/sched_boost
        [ "$ENABLE_IO_TUNING"   = "true" ] && apply_io_sched active
        [ "$ENABLE_SF_TWEAKS"   = "true" ] && apply_sf_tweaks normal
        echo "[TWEAKS] BALANCED" >> "$LOG" 2>/dev/null
        ;;
      ACTIVE|CHARGING)
        apply_schedutil "$POL0" 500 2000
        apply_schedutil "$POL4" 500 2000
        apply_schedutil "$POL6" 500 2000
        safe_write 10 "$SWAP"; safe_write 20 "$VM_DIRTY"
        safe_write 10 "$VM_DIRTY_BG"; safe_write 80 "$VM_CACHE"
        [ "$ENABLE_SCHED_BOOST" = "true" ] && safe_write 0 /proc/sys/kernel/sched_boost
        [ "$ENABLE_IO_TUNING"   = "true" ] && apply_io_sched active
        [ "$ENABLE_SF_TWEAKS"   = "true" ] && apply_sf_tweaks normal
        echo "[TWEAKS] PERF" >> "$LOG" 2>/dev/null
        ;;
      GAMING)
        apply_schedutil "$POL0" 500 500
        apply_schedutil "$POL4" 500 500
        apply_schedutil "$POL6" 500 500
        # swappiness 1: S10 series (6-12 GB) — keep game data fully resident
        safe_write 1 "$SWAP"; safe_write 40 "$VM_DIRTY"
        safe_write 20 "$VM_DIRTY_BG"; safe_write 50 "$VM_CACHE"
        [ "$ENABLE_SCHED_BOOST" = "true" ] && safe_write 1 /proc/sys/kernel/sched_boost
        [ "$ENABLE_IO_TUNING"   = "true" ] && apply_io_sched gaming
        [ "$ENABLE_SF_TWEAKS"   = "true" ] && apply_sf_tweaks gaming
        [ "$ENABLE_GAME_CMD"    = "true" ] && apply_game_cmd enter
        echo "[TWEAKS] GAMING — full clocks, ultra-low latency" >> "$LOG" 2>/dev/null
        ;;
    esac
  }

  on_gaming_exit() {
    [ "$ENABLE_GAME_CMD" = "true" ] && apply_game_cmd exit
  }

  # ─── WebUI permissions ────────────────────────────────────────────────────
  chmod -R 755 "$_MOD_DIR/webroot" 2>/dev/null
  chown -R root:root "$_MOD_DIR/webroot" 2>/dev/null
  chmod 644 "$_MOD_DIR/config.sh" 2>/dev/null

  # ─── Startup sanity check ─────────────────────────────────────────────────
  echo "[INIT] zone5=$(cat $T_SKIN 2>/dev/null || echo MISSING) gov=$(cat $POL0/scaling_governor 2>/dev/null || echo MISSING)" >> "$LOG"
  echo "[INIT] $(echo $GAMING_PACKAGES | wc -w) game packages | Triggers: A=${TEMP_AUTO_TRIGGER} G=${TEMP_GAMING_TRIGGER} S=${TEMP_SAVE_TRIGGER}°C" >> "$LOG"
  [ "$_SAFE_BOOT" = "true" ] && \
    echo "[SAFETY] Grace active — MODE restored to ${_ORIG_MODE} after 24 ticks" >> "$LOG"

  [ "$ENABLE_IO_TUNING" = "true" ] && apply_io_sched active
  [ "$ENABLE_SF_TWEAKS" = "true" ] && apply_sf_tweaks normal

  # ─────────────────────────────────────────────────────────────────────────
  # Main loop  (cycle = 1 s /proc/stat window + LOOP_SLEEP s)
  # ─────────────────────────────────────────────────────────────────────────
  while true; do
    TICK=$((TICK+1))

    # Write boot_ok after first clean tick
    [ "$TICK" -eq 1 ] && touch "$_BOOT_OK" 2>/dev/null && \
      echo "[SAFETY] boot_ok written" >> "$LOG" 2>/dev/null

    # Restore MODE after safe-boot grace (~120 s at default 5 s/tick)
    if [ "$_SAFE_BOOT" = "true" ] && [ "$TICK" -eq 24 ]; then
      MODE="$_ORIG_MODE"; _SAFE_BOOT=false
      echo "[SAFETY] Grace ended — MODE=${MODE}" >> "$LOG" 2>/dev/null
    fi

    SKIN_T=$(get_skin_t)
    CORE_T=$(get_core_t)
    T=$SKIN_T
    [ "$CORE_T" -gt "$T" ] 2>/dev/null && T=$CORE_T

    # ── CPU load — 1 s /proc/stat window ──────────────────────────────────
    read _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat 2>/dev/null
    sleep 1
    read _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat 2>/dev/null
    t1=$((u1+n1+s1+i1+w1+q1+sq1+st1))
    t2=$((u2+n2+s2+i2+w2+q2+sq2+st2))
    dt=$((t2-t1)); di=$((i2-i1))
    IL=0; [ "$dt" -gt 0 ] 2>/dev/null && IL=$(((dt-di)*100/dt))
    L1=$L2; L2=$L3; L3=$IL
    AVG=$(((L1+L2+L3)/3))

    BURST=false
    [ "$IL" -ge "$BURST_THRESH" ] 2>/dev/null && BURST=true

    case "$MODE" in
      gaming)    TRIG=$TEMP_GAMING_TRIGGER ;;
      powersave) TRIG=$TEMP_SAVE_TRIGGER ;;
      *)         TRIG=$TEMP_AUTO_TRIGGER ;;
    esac
    [ "$T" -ge "$TRIG" ] 2>/dev/null && HC=$((HC+1)) || HC=0

    BT=$(cat "$BATT" 2>/dev/null)
    OFF=false; is_off && OFF=true
    NW=$(uptime_s)

    GAMING=false
    if [ "$MODE" = "auto" ] && [ "$OFF" = false ] && \
       [ "$_GAMING_ENABLED" = true ] && is_gaming; then
      GAMING=true
    fi

    if [ "$ST" = "GAMING" ] && [ "$T" -ge "$GAMING_HARD_ABORT" ] 2>/dev/null; then
      GAMING=false
      echo "[GAMING] HARD ABORT — ${T}C >= ${GAMING_HARD_ABORT}C" >> "$LOG" 2>/dev/null
    fi

    # ── Target state decision ──────────────────────────────────────────────
    if [ "$MODE" = "powersave" ]; then
      [ "$OFF" = true ] && TG="POCKET" || TG="POWERSAVE"
    elif [ "$MODE" = "gaming" ]; then
      if   [ "$OFF" = true ]; then TG="POCKET"
      elif [ "$T" -ge "$GAMING_HARD_ABORT" ] 2>/dev/null; then TG="ACTIVE"
      else TG="GAMING"; GAMING=true
      fi
    elif [ "$GAMING" = true ]; then
      TG="GAMING"
    elif [ "$OFF" = true ]; then
      TG="POCKET"
    elif [ "$BT" = "Charging" ] && [ "$SKIN_T" -ge 38 ] 2>/dev/null; then
      TG="CHARGING"
    elif [ "$CORE_T" -ge 45 ] 2>/dev/null || [ "$SKIN_T" -ge 41 ] 2>/dev/null; then
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
    if [ "$TG" != "$ST" ]; then
      _sw=false
      if   [ "$TG" = "GAMING" ] || [ "$ST" = "GAMING" ]; then _sw=true
      elif [ "$TG" = "ACTIVE" ] && [ "$BURST" = true ];   then _sw=true
      elif [ "$ST" = "IDLE"   ] || [ "$ST" = "LIGHT" ];   then _sw=true
      elif [ $((NW - LC)) -ge "$DB" ] 2>/dev/null;         then _sw=true
      fi
      if [ "$_sw" = true ]; then
        echo "[STATE] $ST -> $TG  Skin=${SKIN_T}C Core=${CORE_T}C L=${AVG}% IL=${IL}% Burst=$BURST" >> "$LOG" 2>/dev/null
        [ "$ST" = "GAMING" ] && [ "$TG" != "GAMING" ] && on_gaming_exit
        ST="$TG"; LC=$NW
        apply_tweaks "$ST"
      fi
    fi

    # ── Frequency caps ────────────────────────────────────────────────────
    F0=$M0; F4=$M4; F6=$M6
    case "$ST" in
      GAMING)
        if [ "$GAMING_IGNORE_THERMAL" != "true" ] && \
           [ "$SKIN_T" -ge "$GAMING_THERMAL_CEIL" ] 2>/dev/null; then
          F6=$((M6*80/100))
          echo "[GAMING] Soft cap: BIG -> $F6 Hz (${SKIN_T}C)" >> "$LOG" 2>/dev/null
        fi
        ;;
      POCKET)    F0=600000;           F4=600000;           F6=600000 ;;
      POWERSAVE) F0=$((M0*60/100));   F4=$((M4*60/100));   F6=$((M6*60/100)) ;;
      CHARGING)  F0=$((M0/2));        F4=$((M4/2));        F6=$((M6*40/100)) ;;
      IDLE)      F0=1600000;          F4=1400000;          F6=$M6 ;;
      LIGHT)     F0=1950000;          F4=2000000;          F6=2200000 ;;
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

    # ── Minimum frequency floors (vY.1.2) ─────────────────────────────────
    # GAMING: lock floor to GAMING_MIN_FLOOR_PCT % of stock max OPP to
    # prevent inter-frame frequency droops.
    # All other states: reset to cpuinfo_min_freq (stock minimum).
    if [ "$ST" = "GAMING" ] && [ "${GAMING_MIN_FLOOR_PCT:-0}" -gt 0 ] 2>/dev/null; then
      G0=$((M0 * GAMING_MIN_FLOOR_PCT / 100))
      G4=$((M4 * GAMING_MIN_FLOOR_PCT / 100))
      G6=$((M6 * GAMING_MIN_FLOOR_PCT / 100))
    else
      G0=$(cat "$POL0/cpuinfo_min_freq" 2>/dev/null); G0=${G0:-$MIN0}
      G4=$(cat "$POL4/cpuinfo_min_freq" 2>/dev/null); G4=${G4:-$MIN4}
      G6=$(cat "$POL6/cpuinfo_min_freq" 2>/dev/null); G6=${G6:-$MIN6}
    fi

    safe_write "$G0" "$POL0/scaling_min_freq"
    safe_write "$G4" "$POL4/scaling_min_freq"
    safe_write "$G6" "$POL6/scaling_min_freq"

    # ── Log line ──────────────────────────────────────────────────────────
    _ts=$(date +%H:%M:%S 2>/dev/null || uptime_s)
    echo "[$_ts] $ST Sk=${SKIN_T}C Co=${CORE_T}C H=$HC L=${AVG}% IL=${IL}% max=$((F0/1000))/$((F4/1000))/$((F6/1000)) min=$((G0/1000))/$((G4/1000))/$((G6/1000)) M=$MODE" >> "$LOG" 2>/dev/null

    [ $((TICK % 500)) -eq 0 ] && rotate_log

    sleep "$LOOP_SLEEP"
  done

) > /dev/null 2>"$ERR" &
_BG_PID=$!

wait $_BG_PID
exit 0
