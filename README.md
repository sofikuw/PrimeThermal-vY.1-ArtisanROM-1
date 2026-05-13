  PrimeThermal · ArtisanROM Fork | S10+ Exynos 9820 \* { margin: 0; padding: 0; box-sizing: border-box; } /\* ===== DARK CYBER / TERMINAL THEME ===== \*/ :root { --bg-deep: #0a0c0a; --bg-surface: #101412; --bg-elevated: #181e1a; --border-subtle: #252e28; --border-accent: #3e5a45; --green-primary: #4aff7a; --green-dim: #2a8c4a; --green-glow: rgba(74, 255, 122, 0.12); --amber: #f5b342; --amber-dim: #8a5a1a; --red: #ff5f5f; --blue: #6ad4ff; --text-body: #d4e0d0; --text-muted: #8c9a86; --text-dim: #4a5546; --mono: 'SF Mono', 'IBM Plex Mono', 'Fira Code', monospace; --sans: 'Inter', 'IBM Plex Sans', system-ui, -apple-system, sans-serif; } body { background-color: var(--bg-deep); color: var(--text-body); font-family: var(--sans); font-size: 15px; line-height: 1.65; padding: 0 0 80px 0; } /\* scanline / noise effect \*/ body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-image: repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.08) 0px, rgba(0, 0, 0, 0.08) 2px, transparent 2px, transparent 6px); pointer-events: none; z-index: 0; } .container { max-width: 960px; margin: 0 auto; padding: 0 24px; position: relative; z-index: 2; } /\* ===== HEADER / HERO ===== \*/ .hero { padding: 56px 0 40px; border-bottom: 1px solid var(--border-subtle); margin-bottom: 8px; } .badge { display: inline-flex; align-items: center; gap: 10px; background: var(--green-glow); border: 1px solid var(--green-dim); padding: 6px 16px; font-family: var(--mono); font-size: 11px; font-weight: 500; letter-spacing: 0.16em; text-transform: uppercase; color: var(--green-primary); margin-bottom: 28px; border-radius: 32px; backdrop-filter: blur(2px); } .badge::before { content: "●"; font-size: 10px; color: var(--green-primary); animation: pulse 2s ease-in-out infinite; } @keyframes pulse { 0%, 100% { opacity: 0.5; text-shadow: none; } 50% { opacity: 1; text-shadow: 0 0 6px var(--green-primary); } } h1 { font-family: var(--mono); font-size: clamp(36px, 7vw, 56px); font-weight: 700; letter-spacing: -0.02em; line-height: 1.1; color: white; } h1 span { color: var(--green-primary); } .hero-sub { font-family: var(--mono); font-size: 13px; color: var(--text-muted); margin-top: 12px; margin-bottom: 20px; border-left: 2px solid var(--green-dim); padding-left: 18px; } .hero-desc { max-width: 620px; font-size: 16px; color: var(--text-body); margin: 20px 0 28px; } .tag-strip { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; } .tag { font-family: var(--mono); font-size: 10px; font-weight: 500; padding: 4px 10px; background: var(--bg-surface); border: 1px solid var(--border-subtle); color: var(--text-muted); border-radius: 20px; } .tag.highlight { border-color: var(--green-dim); color: var(--green-primary); background: rgba(74, 255, 122, 0.05); } .tag.warning { border-color: var(--amber-dim); color: var(--amber); } /\* ===== SECTION STYLES ===== \*/ section { margin: 48px 0 24px; } .section-header { display: flex; align-items: center; gap: 16px; margin-bottom: 28px; } .section-header .label { font-family: var(--mono); font-size: 11px; font-weight: 600; letter-spacing: 0.2em; color: var(--text-muted); background: var(--bg-surface); padding: 4px 12px; border-radius: 40px; border: 1px solid var(--border-subtle); } .section-header h2 { font-family: var(--mono); font-size: 22px; font-weight: 600; color: white; letter-spacing: -0.3px; } h3 { font-family: var(--mono); font-size: 14px; font-weight: 600; color: var(--green-primary); margin: 32px 0 12px; letter-spacing: 0.02em; } /\* mode cards grid (fixed visuals) \*/ .mode-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 1px; background: var(--border-subtle); border: 1px solid var(--border-subtle); margin: 28px 0; border-radius: 12px; overflow: hidden; } .mode-card { background: var(--bg-surface); padding: 20px 16px; transition: all 0.15s; } .mode-card:hover { background: var(--bg-elevated); } .mode-name { font-family: var(--mono); font-weight: 700; font-size: 12px; letter-spacing: 0.1em; margin-bottom: 12px; } .mode-card.pocket .mode-name { color: var(--blue); } .mode-card.idle .mode-name { color: var(--green-primary); } .mode-card.light .mode-name { color: #b8f27a; } .mode-card.active .mode-name { color: var(--amber); } .mode-card.charging .mode-name { color: var(--red); } .mode-trigger { font-size: 11px; color: var(--text-muted); line-height: 1.45; margin-bottom: 18px; border-left: 1px solid var(--border-accent); padding-left: 10px; } .mode-freqs { font-family: var(--mono); font-size: 10px; color: var(--text-dim); border-top: 1px solid var(--border-subtle); padding-top: 12px; line-height: 1.7; } /\* sysfs table clean \*/ .sysfs-card { background: var(--bg-surface); border-left: 3px solid var(--green-dim); border-radius: 12px; padding: 6px 0; margin: 24px 0; } .sysfs-row { display: grid; grid-template-columns: 300px 1fr; gap: 20px; padding: 14px 20px; border-bottom: 1px solid var(--border-subtle); align-items: baseline; } .sysfs-row:last-child { border-bottom: none; } .sysfs-path { font-family: var(--mono); font-size: 11px; color: var(--blue); word-break: break-word; } .sysfs-desc { font-size: 12px; color: var(--text-muted); line-height: 1.5; } /\* changelog table \*/ .change-table { width: 100%; border-collapse: collapse; font-size: 13px; margin: 28px 0; background: var(--bg-surface); border-radius: 14px; overflow: hidden; border: 1px solid var(--border-subtle); } .change-table th { text-align: left; font-family: var(--mono); font-size: 10px; letter-spacing: 0.1em; color: var(--text-muted); background: var(--bg-elevated); padding: 14px 18px; border-bottom: 1px solid var(--border-accent); } .change-table td { padding: 14px 18px; border-bottom: 1px solid var(--border-subtle); vertical-align: top; color: var(--text-body); } .change-table tr:last-child td { border-bottom: none; } .change-table td:first-child { font-family: var(--mono); font-weight: 500; color: var(--green-primary); width: 140px; } /\* code blocks \*/ pre { background: #0b0f0c; border: 1px solid var(--border-subtle); border-radius: 16px; padding: 18px 22px; font-family: var(--mono); font-size: 12px; overflow-x: auto; line-height: 1.6; margin: 20px 0; } code { font-family: var(--mono); background: var(--bg-elevated); padding: 2px 8px; border-radius: 20px; font-size: 11px; border: 1px solid var(--border-subtle); color: var(--green-primary); } .log-sample { background: #0a0e0b; border-radius: 16px; padding: 20px; font-family: var(--mono); font-size: 11px; line-height: 1.9; border: 1px solid var(--border-accent); overflow-x: auto; } .steps-list { list-style: none; counter-reset: step-counter; margin: 24px 0; } .steps-list li { counter-increment: step-counter; background: var(--bg-surface); margin-bottom: 10px; padding: 16px 20px 16px 56px; border-radius: 20px; border: 1px solid var(--border-subtle); position: relative; transition: background 0.1s; font-size: 14px; } .steps-list li:hover { background: var(--bg-elevated); } .steps-list li::before { content: counter(step-counter, decimal-leading-zero); position: absolute; left: 18px; top: 16px; font-family: var(--mono); font-weight: 700; font-size: 12px; color: var(--green-primary); background: var(--green-glow); padding: 0 6px; border-radius: 24px; } .credit-glossy { background: var(--bg-surface); border-radius: 20px; padding: 28px 32px; margin: 32px 0; border: 1px solid var(--border-accent); position: relative; } .credit-glossy::after { content: "// UPSTREAM"; position: absolute; top: 24px; right: 28px; font-family: var(--mono); font-size: 10px; color: var(--text-muted); letter-spacing: 0.1em; } .credit-links { display: flex; gap: 14px; margin-top: 20px; flex-wrap: wrap; } .credit-link { font-family: var(--mono); font-size: 11px; border: 1px solid var(--green-dim); padding: 8px 18px; border-radius: 60px; color: var(--green-primary); text-decoration: none; transition: 0.1s; } .credit-link:hover { background: var(--green-glow); border-color: var(--green-primary); } .disclaimer-box { margin: 48px 0 32px; background: rgba(245, 179, 66, 0.05); border-left: 4px solid var(--amber); padding: 22px 28px; border-radius: 24px; font-size: 12px; font-family: var(--mono); color: var(--amber); } .footer { margin-top: 50px; padding-top: 28px; border-top: 1px solid var(--border-subtle); display: flex; justify-content: space-between; flex-wrap: wrap; gap: 20px; font-size: 11px; color: var(--text-muted); font-family: var(--mono); } @media (max-width: 700px) { .sysfs-row { grid-template-columns: 1fr; gap: 6px; } .change-table td:first-child { width: auto; } .mode-grid { grid-template-columns: 1fr 1fr; } }

ACTIVE — Magisk / KernelSU-Next

PrimeThermal
============

vY.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820

Adaptive thermal & CPU frequency manager for Galaxy S10+ (ArtisanROM Quant / OneUI 8). Real-time skin & core sensing, five automatic power modes, and progressive frequency caps to prevent overheating without killing performance.

ArtisanROM Quant KernelSU-Next Exynos 9820 SM-G975F SELinux Enforcing Sysfs-only

01 — Core

Architecture & sensing
----------------------

Background shell loop (`service.sh`) triggers every 5 seconds. It reads thermal zones (skin/CPU clusters) and CPU load average, then applies the optimal mode via sysfs. Mode changes are debounced (15s cooldown) to prevent rapid flickering.

### // Thermal zones (Exynos 9820)

**Skin sensor** (thermal\_zone5) measures surface temperature — primary throttling trigger. **Core sensors** (zones 0,1,2) catch sudden compute spikes. The module uses the maximum of both and applies progressive caps.

### // CPU load & debounce

Three consecutive readings from `/proc/stat` are averaged. Load percentage, combined with temperature and charging state, determines final mode.

02 — Modes

Five adaptive states
--------------------

POCKET

screen off / backlight = 0

LITTLE 600 MHz  
MID 600 MHz  
BIG 600 MHz  
swappiness=100

IDLE

screen on · low temp · load <15%

LITTLE 1.0 GHz  
MID 900 MHz  
BIG 700 MHz  
swappiness=60

LIGHT

skin ≥37°C or load 15–40%

1.3GHz / 1.5GHz / 1.7GHz  
swappiness=60

ACTIVE

skin ≥41°C or load ≥40%

dynamic caps (see heat table)  
swappiness=10

CHARGING

charging + skin ≥38°C

975/1157/1092 MHz  
swappiness=10

### ▼ ACTIVE mode thermal steps (progressive)

\# sustained heat ≥ 2 cycles (10+ sec)
T ≥ 44°C  →  50% OPP  (975 / 1157 / 1365 MHz)
T ≥ 42°C  →  65% OPP  (1267 / 1504 / 1774 MHz)
T ≥ 40°C  →  80% OPP  (1560 / 1851 / 2184 MHz)
T < 40°C   →  full OPP (1950 / 2314 / 2730 MHz)

03 — Sysfs Interface

Nodes read & written
--------------------

/sys/class/thermal/thermal\_zone5/tempSkin / PCB temp (primary decision)

/sys/class/thermal/thermal\_zone6/tempBattery temperature fallback

/sys/class/thermal/thermal\_zone{0,1,2}/tempCPU clusters (LITTLE, MID, BIG)

/sys/devices/system/cpu/cpufreq/policy\*/scaling\_max\_freqHard frequency cap (cluster 0/4/6)

/sys/.../schedutil/up\_rate\_limit\_usFrequency ramp-up aggressiveness

/sys/class/power\_supply/battery/statusCharging detection (status=Charging)

/sys/class/backlight/\*/brightnessScreen state (probes panel0 / s6e3ha9 etc.)

/proc/sys/vm/swappinessSwap tendency — raised in idle/pocket modes

04 — Fork changes

ArtisanROM adaptations
----------------------

Area

Upstream assumption

ArtisanROM reality & fix

compact\_memory

Written each mode switch

ArtisanKRNL (Linux 5.x+) removed /proc/sys/vm/compact\_memory – node completely dropped from fork.

Governor detection

Probed interactive/ondemand/schedutil

Upstreamed kernel ships schedutil only; interactive/ondemand removed. Simplified to schedutil exclusive, added rate\_limit\_us fallback.

Thermal zone probing

Probed zones 0–9 (assumed HAL renumbering)

ArtisanROM registers zones directly from DTS: zone5=skin, zone6=battery, zones0-2=CPU clusters. Hardcoded – probing removed.

Screen detection

backlight → SurfaceFlinger grep → dumpsys

SF format unreliable; now uses backlight node (probes panel0-backlight, s6e3ha9, s6e3hc2) + dumpsys power fallback.

Backlight path

Only panel0-backlight

S10+ uses s6e3ha9 AMOLED driver; module auto-probes 4 panel paths and logs result.

Log location

/data/local/tmp/

KernelSU-Next → preferred path /data/adb/modules/PrimeThermalArtisanROM/ (avoids SELinux strict context).

Samsung thermal daemon

Potential sec\_ts conflict

ArtisanROM is heavily DeKnoxed; Samsung thermal daemon stripped – sysfs writes uncontested.

05 — Logging

Real‑time monitoring
--------------------

Log rotated at 1000 lines. Path: `/data/adb/modules/PrimeThermalArtisanROM/thermal.log` (fallback `/data/local/tmp/s10_thermal.log`)

\[INIT\] PrimeThermal vY.1 started PID=1337  
\[TWEAKS\] PERF applied  
\[09:00:06\] ACTIVE Skin=28C Core=31C Load=22% F6=2730000  
\[STATE\] ACTIVE → LIGHT (Skin=39C load=12%)  
\[09:01:43\] LIGHT Skin=37C Core=41C freq\_cap=1700000

Tail with: `su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`

06 — Installation

Flash & forget
--------------

*   Confirm you are on **ArtisanROM Quant** with **KernelSU-Next** installed and root granted.
*   Download **PrimeThermal-vY.1-ArtisanROM.zip** (build from fork).
*   Open KernelSU app → **Modules** → tap **➕** → select the ZIP file.
*   Wait for installation → **Reboot**.
*   After reboot, verify log: `su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`

Uninstall: disable / remove module in KernelSU → reboot. All sysfs changes are volatile.

PrimeThermal v1.1-OneUI

by [Prime1337](https://github.com/igoraotel-a11y/PrimeThermal) · original thermal state machine & dual-sensor logic

This ArtisanROM fork preserves upstream credit while adapting sysfs paths, governor handling, and backlight detection for the S10+ on upstreamed Exynos 9820 kernel. All core adaptive logic remains attributed to Prime1337.

[↗ Upstream Repo](https://github.com/igoraotel-a11y/PrimeThermal) [↗ Telegram](https://t.me/PrimeThermal)

Additional thanks: ArtisanROM, Android-Artisan (kernel), KernelSU-Next, CruelKernel, UN1CA

**⚠️ DISCLAIMER**  
This module modifies CPU frequency limits and schedutil parameters in real time. All changes are reset after reboot. Use at your own risk. Not affiliated with Samsung, ArtisanROM or original PrimeThermal. Monitor thermals during first usage.

PrimeThermal vY.1-ArtisanROM · Fork for SM-G975F · Exynos 9820  
OneUI 8 / Android 16 · KernelSU-Next

GPL-3.0 · Upstream: igoraotel-a11y/PrimeThermal