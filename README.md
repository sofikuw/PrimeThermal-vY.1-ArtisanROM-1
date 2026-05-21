# PrimeThermal vY.1.2-ArtisanROM

Adaptive thermal and CPU governor manager for the **Samsung Galaxy S10 series (S10e · S10 · S10+, Exynos 9820)** running ArtisanROM Quant · OneUI 8 · Android 16 · KernelSU-Next · ArtisanKRNL.

---

## Requirements

| Requirement | Detail |
|---|---|
| Device | SM-G970F (S10e / beyond0lte) **or** SM-G973F (S10 / beyond1lte) **or** SM-G975F (S10+ / beyond2lte) |
| SoC | Exynos 9820 (all three share identical cpufreq topology and thermal zones) |
| ROM | ArtisanROM Quant (OneUI 8 / Android 16) |
| Root | KernelSU-Next |
| Kernel | ArtisanKRNL (upstreamed Linux 5.x, schedutil only) |
| Manager | MMRL or KSU app (for WebUI) |

---

## How it works

A background shell daemon reads skin/core temperatures and CPU load once per tick (~5 s). It transitions between seven states and applies matching clock caps, schedutil parameters, and system tweaks:

| State | When | Behaviour |
|---|---|---|
| `IDLE` | Low load, cool | Caps at 1.6/1.4/stock GHz, relaxed schedutil |
| `LIGHT` | Moderate load | Caps at stock/2.0/2.2 GHz |
| `ACTIVE` | High load or warm | Dynamic caps at 50–100 % based on temp |
| `GAMING` | Game package in foreground | Full stock OPPs, min-freq floor, SF tweaks |
| `POWERSAVE` | `MODE=powersave` set | All clusters at 60 % |
| `CHARGING` | Charging + warm | Half-speed caps to reduce heat |
| `POCKET` | Screen off | All clusters at 600 MHz |

---

## Configuration

Edit `/data/adb/modules/PrimeThermalArtisanROM/config.sh` or use the **WebUI** in MMRL / KSU-Next app. Changes take effect on next reboot.

### Key options

```sh
MODE=auto                  # auto | gaming | powersave
GAMING_MIN_FLOOR_PCT=50    # % of max OPP locked as min_freq in GAMING (0 = off)
BURST_THRESH=25            # single-tick load % that triggers instant ACTIVE
LOOP_SLEEP=4               # sleep between ticks (actual cycle = +1 s)
GAMING_HARD_ABORT=54       # °C — force-exits GAMING regardless of settings
GAMING_THERMAL_CEIL=48     # °C — soft-caps BIG cluster to 80 % in GAMING
ENABLE_SF_TWEAKS=true      # SurfaceFlinger latency props in GAMING
ENABLE_IO_TUNING=true      # I/O scheduler: deadline gaming, cfq idle
ENABLE_SCHED_BOOST=true    # /proc/sys/kernel/sched_boost in GAMING
ENABLE_GAME_CMD=true       # Android Game Manager API (Android 12+)
```

---

## Files

```
PrimeThermalArtisanROM/
├── service.sh       Main daemon — state machine, governor, all tweaks
├── config.sh        User configuration — edit this
├── module.prop      Module metadata
├── thermal.log      Runtime log (rotated at 1000 lines)
├── thermal.err      stderr from daemon
├── boot_ok          Bootloop guard flag (auto-managed)
└── webroot/
    └── index.html   MMRL/KSU-Next WebUI
```

---

## WebUI

Open the module card in **MMRL** or the **KSU-Next** app to access the WebUI. It provides:

- Live status: state badge, temperatures, CPU load, HC counter
- Mode toggle (Auto / Gaming / Powersave) — writes `config.sh`
- Feature toggles for each vY.1.2 enhancement
- Gaming min-freq floor adjustment
- Live log tail (auto-refreshes every 10 s)
- Gamelist editor — add/remove packages, save with one tap

---

## Bootloop guard

If the module crashes before completing the first loop tick, `boot_ok` will be absent on the next boot. The daemon will run in forced `POWERSAVE` for ~120 s, then restore your configured `MODE`. This prevents a crash from causing a permanent bootloop.

---

## Logs

```sh
cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log
cat /data/adb/modules/PrimeThermalArtisanROM/thermal.err
```

---

## Credits

### Upstream — PrimeThermal by igoraotel-a11y (Prime1337)
**https://github.com/igoraotel-a11y/PrimeThermal**

The entire core of this module — the state machine (IDLE / LIGHT / ACTIVE / POCKET / CHARGING), dual thermal sensor logic (skin + core), schedutil tuning, frequency cap tables, log rotation, and the overall shell-daemon architecture — is the work of **igoraotel-a11y**, known in the community as **Prime1337**. This ArtisanROM fork would not exist without that upstream.

---

### Third-party

| Project | Author | License | What was used |
|---|---|---|---|
| [Encore Tweaks](https://github.com/Rem01Gaming/encore) | Rem01Gaming | Apache-2.0 | `gamelist.txt` — 530+ game package names merged into `GAMING_PACKAGES`. Only the data was used; no Encore code runs in this module. |
| [Gaming-X Magisk Module](https://github.com/JordanTweaks/Gaming-X-Magisk-Module) | JordanTweaks | GPL-3.0 | SurfaceFlinger `debug.sf.*` property pattern (`apply_sf_tweaks`) and Android Game Manager API call pattern (`apply_game_cmd`) were adapted. No code was copied verbatim — both were re-implemented from scratch to fit PrimeThermal's state-machine structure. |
| [SpeedCool Magisk Module](https://github.com/Llucs/SpeedCool-Magisk-Module) | Llucs | — | Bootloop Recovery System concept — the `boot_ok` flag + forced safe-mode grace period on startup was inspired by SpeedCool's approach. |
