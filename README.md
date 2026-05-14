# PrimeThermal

  **vY.1.1.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820**

  > Adaptive thermal & CPU frequency manager for Galaxy S10+ on ArtisanROM Quant.

  [![Version](https://img.shields.io/badge/version-vY.1.1.1--ArtisanROM-00e5ff?style=flat-square)](https://github.com/sofikuw/PrimeThermal-vY.1-ArtisanROM-1/releases)
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

  1. Download `PrimeThermal-vY_1_1_1-ArtisanROM.zip` from the Releases page.
  2. Open **KernelSU** → Modules → tap **+** → select the ZIP.
  3. Reboot.
  4. Verify: `su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`

  ---

  ## Modes

  | Mode | Trigger | LITTLE | MID | BIG | Swappiness |
  |---|---|---|---|---|---|
  | **POCKET** | Screen off | 600 MHz | 600 MHz | 600 MHz | 100 |
  | **POWERSAVE** | `MODE=powersave` | 1170 MHz | 1388 MHz | 1638 MHz | 100 |
  | **IDLE** | Low load, cool | 1600 MHz | 1400 MHz | **2730 MHz** (uncapped) | 100 |
  | **LIGHT** | Skin ≥ 37 °C or load 15–40 % | 1950 MHz | 2000 MHz | 2200 MHz | 60 |
  | **ACTIVE** | Skin ≥ 41 °C or load ≥ 25 % burst | dynamic steps | dynamic | dynamic | 10 |
  | **CHARGING** | Charging + skin ≥ 38 °C | 975 MHz | 1157 MHz | 1092 MHz | 10 |
  | **GAMING** | Game in foreground or `MODE=gaming` | 1950 MHz | 2314 MHz | 2730 MHz* | 10 |

  *BIG backs to 80 % at `GAMING_THERMAL_CEIL` (48 °C). Hard abort at `GAMING_HARD_ABORT` (54 °C).

  ---

  ## Configuration (`config.sh`)

  ```
  /data/adb/modules/PrimeThermalArtisanROM/config.sh
  ```

  | Variable | Default | Description |
  |---|---|---|
  | `MODE` | `auto` | `auto` / `gaming` / `powersave` |
  | `ENABLE_LOG` | `true` | `false` silences all log I/O |
  | `BURST_THRESH` | `25` | Single-tick load % that triggers instant ACTIVE |
  | `LOOP_SLEEP` | `1` | Sleep between checks (actual cycle = LOOP_SLEEP + 1 s) |
  | `GAMING_PACKAGES` | 15 titles | Space-separated game packages |
  | `GAMING_IGNORE_THERMAL` | `false` | Skip soft thermal cap in GAMING mode |
  | `GAMING_THERMAL_CEIL` | `48` | Soft cap temperature (°C) |
  | `GAMING_HARD_ABORT` | `54` | Hard abort temperature (°C) |
  | `TEMP_AUTO_TRIGGER` | `42` | HC counter threshold in auto mode (°C) |
  | `TEMP_GAMING_TRIGGER` | `45` | HC counter threshold in gaming mode (°C) |
  | `TEMP_SAVE_TRIGGER` | `38` | HC counter threshold in powersave mode (°C) |

  ---

  ## WebUI

  Open the module card in MMRL or KernelSU-Next and tap the WebUI button.

  ---

  ## Logging

  ```sh
  su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'
  ```

  ---

  ## Credits

  **PrimeThermal v1.1-OneUI** by [Prime1337 / igoraotel-a11y](https://github.com/igoraotel-a11y/PrimeThermal).  
  **Additional thanks:** ArtisanROM, Android-Artisan, KernelSU-Next.

  ---

  ## Disclaimer

  Modifies CPU frequency limits and schedutil parameters in real time via sysfs. All changes are volatile and reset on reboot. Use at your own risk.

  ---

  ## Changelog

  ### [vY.1.1.1-ArtisanROM] — 2026-05-14

  - **Loop cycle 5 s → 2 s** (`LOOP_SLEEP` 4 → 1) — module reacts within 2 s instead of 5 s. App launches, keyboard opens, recents, and tab switches were being missed almost every cycle; now caught reliably.
  - **BURST threshold 60 % → 25 %** (`BURST_THRESH`) — catches light UI loads like keyboard open (~20 %) and tab switching (~15–25 %) in addition to scroll/swipe bursts. Still configurable in `config.sh`.
  - **IDLE & LIGHT exit instant** — any upgrade out of IDLE or LIGHT (to ACTIVE) bypasses the 15 s debounce. Covers app launch, recents menu, keyboard, tab switches, and swipe gestures.
  - **IDLE BIG cluster uncapped** — removed the 1600 MHz ceiling in IDLE; schedutil can use full stock 2730 MHz freely when the device is cool. Thermal protection still active via mode transitions.
  - **IDLE `down_rate_limit_us` 8000 µs → 4000 µs** — smoother governor drop after animation/scroll bursts.
    
  ### [vY.1.1-ArtisanROM] — 2026-05-14

  GAMING mode, POWERSAVE mode, BURST detection, WebUI, hard abort, mode-specific HC triggers, raised IDLE/LIGHT floors, 500 µs up-rate on all modes, log rotation, HH:MM:SS timestamps.

  ### [vY.1.0-ArtisanROM] — 2026-05-13

  Initial fork from PrimeThermal v1.1-OneUI. Five adaptive modes, ArtisanKRNL compatibility, log path, backlight auto-probing.

  ### Upstream — PrimeThermal v1.1-OneUI

  Original work by [Prime1337 / igoraotel-a11y](https://github.com/igoraotel-a11y/PrimeThermal). Core adaptive state machine and dual-sensor logic. Derivative under GPL-3.0.

  ---

  **PrimeThermal vY.1.1.1-ArtisanROM · SM-G975F · Exynos 9820 · GPL-3.0**
  