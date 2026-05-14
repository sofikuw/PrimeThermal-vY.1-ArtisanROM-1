#!/system/bin/sh
# ═══════════════════════════════════════════════════════════════
# PrimeThermal vY.1.1-ArtisanROM — User Configuration
# Edit this file to customise module behaviour.
# Changes take effect on next reboot (module re-sources this file).
# ═══════════════════════════════════════════════════════════════

# ── Operating mode ─────────────────────────────────────────────
# auto      → normal adaptive logic (recommended)
# gaming    → forces GAMING clocks whenever screen is on
#             (no package detection needed — always max clocks)
# powersave → caps all clusters at 60 % and uses conservative
#             schedutil; useful for battery-critical situations
MODE=auto

# ── Logging ────────────────────────────────────────────────────
# true  → write thermal.log (normal operation)
# false → silence all log output; zero I/O overhead
ENABLE_LOG=true

# ── Gaming Mode — package list ─────────────────────────────────
# Space-separated game package names. When ANY of these is in the
# foreground (auto mode only), PrimeThermal enters GAMING mode:
# full stock clocks, schedutil at 500/500 µs, swappiness 10.
# The WebUI (MMRL/KSU module card) can edit this list live.
#
GAMING_PACKAGES="
  com.activision.callofduty.shooter
  com.tencent.ig
  com.pubg.krmobile
  com.vng.pubgmobile
  com.gameloft.android.ANMP.GloftA9HM
  com.ea.game.nfs14_row
  com.mojang.minecraftpe
  com.dts.freefireth
  com.dts.freefiremax
  com.riotgames.league.wildrift
  com.miHoYo.GenshinImpact
  com.miHoYo.Honkai3rd
  com.madfingergames.legends
  com.netease.letsplayen
  com.mobile.legends
"

# ── Gaming Mode — thermal soft cap ─────────────────────────────
# GAMING_IGNORE_THERMAL=false → BIG cluster backs off to 80 %
#   when skin reaches GAMING_THERMAL_CEIL. LITTLE/MID stay at max.
# GAMING_IGNORE_THERMAL=true  → all clusters stay at full stock
#   regardless of temperature. Use with caution (see HARD ABORT).
GAMING_IGNORE_THERMAL=false

# Soft cap threshold (°C). Only active when GAMING_IGNORE_THERMAL=false.
GAMING_THERMAL_CEIL=48

# ── Gaming Mode — hard abort temperature ───────────────────────
# When skin reaches this threshold, GAMING mode is force-exited to
# ACTIVE regardless of GAMING_IGNORE_THERMAL. Protects hardware.
# Must be > GAMING_THERMAL_CEIL. Default: 54.
GAMING_HARD_ABORT=54

# ── Thermal trigger temperatures (°C) ──────────────────────────
# HC (heat counter) increments when effective temperature exceeds
# the trigger for the current mode. ACTIVE thermal steps kick in
# after 2+ consecutive HC increments (≥ 10 s).
TEMP_AUTO_TRIGGER=42      # used in auto mode
TEMP_GAMING_TRIGGER=45    # used in gaming mode (tolerates more heat)
TEMP_SAVE_TRIGGER=38      # used in powersave mode (throttles earlier)

# ── Loop timing ────────────────────────────────────────────────
# Sleep between thermal checks (seconds).
# NOTE: actual loop cycle = LOOP_SLEEP + 1 s (1 s /proc/stat window).
# Default: 4 → actual cycle ~5 s.  Range: 2–10.
LOOP_SLEEP=4

# ─── WebUI permissions (sourced by service.sh) ───────────────────
if [ -d "$_MOD_DIR/webroot" ]; then
  chmod -R 755 "$_MOD_DIR/webroot" 2>/dev/null
  [ -f "$_MOD_DIR/$COVER_IMAGE" ] && \
    ln -sf "$_MOD_DIR/$COVER_IMAGE" "$_MOD_DIR/webroot/cover.png" 2>/dev/null
fi
