# PrimeThermal

**vY.1.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820**

> Adaptive thermal & CPU frequency manager for Galaxy S10+ on ArtisanROM Quant.  
> Real-time skin & core sensing, seven automatic power modes (including GAMING and POWERSAVE), progressive frequency caps, burst-detection, and a user-editable WebUI.

[![Version](https://img.shields.io/badge/version-vY.1.1--ArtisanROM-00e5ff?style=flat-square)](https://github.com/sofikuw/PrimeThermal-vY.1-ArtisanROM-1/releases)
[![Device](https://img.shields.io/badge/device-SM--G975F%20beyond2lte-39ff82?style=flat-square)]()
[![ROM](https://img.shields.io/badge/ROM-ArtisanROM%20Quant-ff6b35?style=flat-square)]()
[![KernelSU](https://img.shields.io/badge/root-KernelSU--Next-ffbe00?style=flat-square)]()
[![License](https://img.shields.io/badge/license-GPL--3.0-555?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Upstream](https://img.shields.io/badge/upstream-igoraotel--a11y%2FPrimeThermal-9b9b9b?style=flat-square)](https://github.com/igoraotel-a11y/PrimeThermal)

---

## Requirements

| Requirement | Detail |
|---|---|
| Device | Samsung Galaxy S10+ `SM-G975F` (`beyond2lte`) |
| ROM | ArtisanROM Quant (OneUI 8 / Android 16) |
| Kernel | ArtisanKRNL (upstreamed Linux 5.x, `schedutil` only) |
| Root | KernelSU-Next |
| SELinux | Enforcing (supported) |

---

## Installation

1. Download `PrimeThermal-vY_1_1-ArtisanROM.zip` from the Releases page.
2. Open **KernelSU** → Modules → tap **+** → select the ZIP.
3. Reboot.
4. Verify: `su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`

---

## Seven adaptive modes

| Mode | Trigger | LITTLE | MID | BIG | Swappiness |
|---|---|---|---|---|---|
| **POCKET** | Screen off | 600 MHz | 600 MHz | 600 MHz | 100 |
| **POWERSAVE** | `MODE=powersave` | 1170 MHz | 1388 MHz | 1638 MHz | 100 |
| **IDLE** | Low load, cool | 1600 MHz | 1400 MHz | 1200 MHz | 100 |
| **LIGHT** | Skin ≥ 37 °C or load 15–40 % | 1950 MHz | 2000 MHz | 2200 MHz | 60 |
| **ACTIVE** | Skin ≥ 41 °C or load ≥ 40 % or BURST | dynamic steps | dynamic | dynamic | 10 |
| **CHARGING** | Charging + skin ≥ 38 °C | 975 MHz | 1157 MHz | 1092 MHz | 10 |
| **GAMING** | Game in foreground (auto) or `MODE=gaming` | 1950 MHz | 2314 MHz | 2730 MHz* | 10 |

*BIG backs to 80 % at `GAMING_THERMAL_CEIL` (48 °C). Hard abort forces exit at `GAMING_HARD_ABORT` (54 °C).

---

## Configuration (`config.sh`)

```
/data/adb/modules/PrimeThermalArtisanROM/config.sh
```

| Variable | Default | Description |
|---|---|---|
| `MODE` | `auto` | `auto` / `gaming` / `powersave` — overrides auto-detection |
| `ENABLE_LOG` | `true` | `false` silences all log I/O |
| `GAMING_PACKAGES` | 15 titles | Space-separated game packages (auto mode only) |
| `GAMING_IGNORE_THERMAL` | `false` | Skip soft thermal cap in GAMING mode |
| `GAMING_THERMAL_CEIL` | `48` | Soft cap: BIG backs to 80 % above this (°C) |
| `GAMING_HARD_ABORT` | `54` | Hard abort: forces exit from GAMING to ACTIVE above this (°C) |
| `TEMP_AUTO_TRIGGER` | `42` | HC counter threshold in auto mode (°C) |
| `TEMP_GAMING_TRIGGER` | `45` | HC counter threshold in gaming mode (°C) |
| `TEMP_SAVE_TRIGGER` | `38` | HC counter threshold in powersave mode (°C) |
| `LOOP_SLEEP` | `4` | Sleep between checks (actual cycle = LOOP_SLEEP + 1 s) |

---

## WebUI

Open the module card in MMRL or KernelSU-Next and tap the WebUI button.

- Switch `MODE` between Auto / Gaming / Powersave
- Toggle `ENABLE_LOG` on or off
- Add or remove game packages from `GAMING_PACKAGES`

---

## Logging

```sh
# Live tail
su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'
```

Log rotates automatically every 500 loop ticks (~41 minutes at default settings).

---

## Credits

**PrimeThermal v1.1-OneUI** by [Prime1337 / igoraotel-a11y](https://github.com/igoraotel-a11y/PrimeThermal) — original thermal state machine and dual-sensor logic.

**Additional thanks:** ArtisanROM, Android-Artisan (kernel), KernelSU-Next

---

## Disclaimer

Modifies CPU frequency limits and schedutil parameters in real time via sysfs. All changes are volatile and reset on reboot. Use at your own risk.

---

## Changelog

### [vY.1.1-ArtisanROM] — 2026-05-14 (current)

#### Added vs upstream V1.2
- **POWERSAVE mode** — 60 % stock clocks, conservative schedutil (up=2000 / dn=12000 µs); activated via `MODE=powersave` or WebUI.
- **`MODE` override** — `auto` / `gaming` / `powersave`; `MODE=gaming` forces full stock clocks without package detection.
- **`ENABLE_LOG`** — `false` silences all output at shell level (zero I/O overhead).
- **Mode-specific HC trigger temps** — `TEMP_AUTO_TRIGGER`, `TEMP_GAMING_TRIGGER`, `TEMP_SAVE_TRIGGER`; HC threshold varies by active mode.
- **GAMING hard abort** — `GAMING_HARD_ABORT` (default 54 °C) forces exit from GAMING to ACTIVE regardless of `GAMING_IGNORE_THERMAL`. Hardware protection that V1.2 lacks entirely.
- **GAMING mode** — full stock clocks on all three clusters when a game package is in the foreground (auto mode) or `MODE=gaming`. V1.2 has no GAMING mode.
- **BURST detection** — single-tick raw load ≥ 60 % triggers immediate ACTIVE, bypassing 3-tick rolling average and 15 s debounce. V1.2 has no burst detection.
- **WebUI** — MMRL/KSU-served UI for MODE switch, ENABLE_LOG toggle, and GAMING_PACKAGES editor. V1.2 has no WebUI.
- **Cover image** — symlinked at startup for MMRL card and KSU-Next module display. V1.2 has no cover image.

#### Better than V1.2
- **IDLE freq floors** raised to 1600/1400/1200 MHz (V1.2: 1000/900/700 MHz) — no stutter on a cool device.
- **LIGHT freq floors** raised to 1950/2000/2200 MHz (V1.2: 1300/1500/1700 MHz) — near-stock under moderate load.
- **`schedutil up_rate_limit_us` = 500 µs on all modes** (V1.2: 2000 µs IDLE / 1000 µs LIGHT / 500 µs ACTIVE) — governor reacts in <1 ms to any burst regardless of current mode.
- **Debounce timer reads `/proc/uptime`** — no shell fork (V1.2 uses `date +%s`, ~5–10 ms fork overhead per tick).
- **Log rotation unconditionally every 500 ticks** (~41 min at 5 s/tick) — V1.2 only rotates on state transitions; log overflows during long stable sessions.
- **Human-readable HH:MM:SS timestamps** in log lines — easier to correlate with real time.
- **`is_gaming()` anchored with `head -1`** — prevents false-positive package match from stray strings in dumpsys output.
- **`chmod 644 config.sh`** — V1.2 did not set WebUI permissions; our original fork used 666 (world-writable, security risk). Fixed to 644.
- **Loop timing documented** — actual cycle = LOOP_SLEEP + 1 s (1 s `/proc/stat` window). Both V1.2 and our earlier build stated "4 s" but ran at 5 s. Startup log now prints the real interval.
- **Full mode logged per tick** — log line includes `M=MODE` field for easier diagnosis of active override.

---

### [vY.1.0-ArtisanROM] — 2026-05-13

Initial fork from `PrimeThermal v1.1-OneUI` by Prime1337.

- `module.prop` updated for ArtisanROM Quant / sofikuw.
- Removed `compact_memory` writes (node absent in Linux 5.18+).
- Schedutil-only governor; thermal zones hardcoded from upstream Exynos 9820 DTS.
- Backlight auto-probing across 4 sysfs paths; `dumpsys power` fallback.
- Log path moved to `/data/adb/modules/PrimeThermalArtisanROM/`.
- Five adaptive modes: POCKET / IDLE / LIGHT / ACTIVE / CHARGING.
- Progressive ACTIVE thermal steps at 40 / 42 / 44 °C.

---

### Upstream — PrimeThermal v1.1-OneUI

Original work by [Prime1337 / igoraotel-a11y](https://github.com/igoraotel-a11y/PrimeThermal).  
Core adaptive state machine and dual-sensor logic are attributed to the upstream project.  
This fork is a derivative work under GPL-3.0.

---

**PrimeThermal vY.1.1-ArtisanROM · SM-G975F · Exynos 9820 · GPL-3.0**
