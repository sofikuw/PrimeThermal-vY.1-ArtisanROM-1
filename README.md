::: container
::: hero
::: badge
ACTIVE --- Magisk / KernelSU-Next
:::

# PrimeThermal

::: hero-sub
vY.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820
:::

Adaptive thermal & CPU frequency manager for Galaxy S10+ (ArtisanROM
Quant / OneUI 8). Real-time skin & core sensing, five automatic power
modes, and progressive frequency caps to prevent overheating without
killing performance.

::: tag-strip
[ArtisanROM Quant]{.tag .highlight} [KernelSU-Next]{.tag .highlight}
[Exynos 9820]{.tag} [SM-G975F]{.tag} [SELinux Enforcing]{.tag .warning}
[Sysfs-only]{.tag}
:::
:::

::: section
::: section-header
[01 --- Core]{.label}

## Architecture & sensing
:::

Background shell loop (`service.sh`) triggers every 5 seconds. It reads
thermal zones (skin/CPU clusters) and CPU load average, then applies the
optimal mode via sysfs. Mode changes are debounced (15s cooldown) to
prevent rapid flickering.

### // Thermal zones (Exynos 9820)

**Skin sensor** (thermal_zone5) measures surface temperature --- primary
throttling trigger. **Core sensors** (zones 0,1,2) catch sudden compute
spikes. The module uses the maximum of both and applies progressive
caps.

### // CPU load & debounce

Three consecutive readings from `/proc/stat` are averaged. Load
percentage, combined with temperature and charging state, determines
final mode.
:::

::: section
::: section-header
[02 --- Modes]{.label}

## Five adaptive states
:::

::: mode-grid
::: {.mode-card .pocket}
::: mode-name
POCKET
:::

::: mode-trigger
screen off / backlight = 0
:::

::: mode-freqs
LITTLE 600 MHz\
MID 600 MHz\
BIG 600 MHz\
swappiness=100
:::
:::

::: {.mode-card .idle}
::: mode-name
IDLE
:::

::: mode-trigger
screen on · low temp · load \<15%
:::

::: mode-freqs
LITTLE 1.0 GHz\
MID 900 MHz\
BIG 700 MHz\
swappiness=60
:::
:::

::: {.mode-card .light}
::: mode-name
LIGHT
:::

::: mode-trigger
skin ≥37°C or load 15--40%
:::

::: mode-freqs
1.3GHz / 1.5GHz / 1.7GHz\
swappiness=60
:::
:::

::: {.mode-card .active}
::: mode-name
ACTIVE
:::

::: mode-trigger
skin ≥41°C or load ≥40%
:::

::: mode-freqs
dynamic caps (see heat table)\
swappiness=10
:::
:::

::: {.mode-card .charging}
::: mode-name
CHARGING
:::

::: mode-trigger
charging + skin ≥38°C
:::

::: mode-freqs
975/1157/1092 MHz\
swappiness=10
:::
:::
:::

### ▼ ACTIVE mode thermal steps (progressive)

    # sustained heat ≥ 2 cycles (10+ sec)
    T ≥ 44°C  →  50% OPP  (975 / 1157 / 1365 MHz)
    T ≥ 42°C  →  65% OPP  (1267 / 1504 / 1774 MHz)
    T ≥ 40°C  →  80% OPP  (1560 / 1851 / 2184 MHz)
    T < 40°C   →  full OPP (1950 / 2314 / 2730 MHz)
:::

::: section
::: section-header
[03 --- Sysfs Interface]{.label}

## Nodes read & written
:::

::: sysfs-card
::: sysfs-row
[/sys/class/thermal/thermal_zone5/temp]{.sysfs-path}[Skin / PCB temp
(primary decision)]{.sysfs-desc}
:::

::: sysfs-row
[/sys/class/thermal/thermal_zone6/temp]{.sysfs-path}[Battery temperature
fallback]{.sysfs-desc}
:::

::: sysfs-row
[/sys/class/thermal/thermal_zone{0,1,2}/temp]{.sysfs-path}[CPU clusters
(LITTLE, MID, BIG)]{.sysfs-desc}
:::

::: sysfs-row
[/sys/devices/system/cpu/cpufreq/policy\*/scaling_max_freq]{.sysfs-path}[Hard
frequency cap (cluster 0/4/6)]{.sysfs-desc}
:::

::: sysfs-row
[/sys/\.../schedutil/up_rate_limit_us]{.sysfs-path}[Frequency ramp-up
aggressiveness]{.sysfs-desc}
:::

::: sysfs-row
[/sys/class/power_supply/battery/status]{.sysfs-path}[Charging detection
(status=Charging)]{.sysfs-desc}
:::

::: sysfs-row
[/sys/class/backlight/\*/brightness]{.sysfs-path}[Screen state (probes
panel0 / s6e3ha9 etc.)]{.sysfs-desc}
:::

::: sysfs-row
[/proc/sys/vm/swappiness]{.sysfs-path}[Swap tendency --- raised in
idle/pocket modes]{.sysfs-desc}
:::
:::
:::

::: section
::: section-header
[04 --- Fork changes]{.label}

## ArtisanROM adaptations
:::

  Area                     Upstream assumption                           ArtisanROM reality & fix
  ------------------------ --------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------
  compact_memory           Written each mode switch                      ArtisanKRNL (Linux 5.x+) removed /proc/sys/vm/compact_memory -- node completely dropped from fork.
  Governor detection       Probed interactive/ondemand/schedutil         Upstreamed kernel ships schedutil only; interactive/ondemand removed. Simplified to schedutil exclusive, added rate_limit_us fallback.
  Thermal zone probing     Probed zones 0--9 (assumed HAL renumbering)   ArtisanROM registers zones directly from DTS: zone5=skin, zone6=battery, zones0-2=CPU clusters. Hardcoded -- probing removed.
  Screen detection         backlight → SurfaceFlinger grep → dumpsys     SF format unreliable; now uses backlight node (probes panel0-backlight, s6e3ha9, s6e3hc2) + dumpsys power fallback.
  Backlight path           Only panel0-backlight                         S10+ uses s6e3ha9 AMOLED driver; module auto-probes 4 panel paths and logs result.
  Log location             /data/local/tmp/                              KernelSU-Next → preferred path /data/adb/modules/PrimeThermalArtisanROM/ (avoids SELinux strict context).
  Samsung thermal daemon   Potential sec_ts conflict                     ArtisanROM is heavily DeKnoxed; Samsung thermal daemon stripped -- sysfs writes uncontested.
:::

::: section
::: section-header
[05 --- Logging]{.label}

## Real‑time monitoring
:::

Log rotated at 1000 lines. Path:
`/data/adb/modules/PrimeThermalArtisanROM/thermal.log` (fallback
`/data/local/tmp/s10_thermal.log`)

::: log-sample
[\[INIT\]]{style="color:#4aff7a"} PrimeThermal vY.1 started PID=1337\
[\[TWEAKS\]]{style="color:#4aff7a"} PERF applied\
[\[09:00:06\]]{style="color:#6ad4ff"} [ACTIVE]{style="color:#f5b342"}
Skin=28C Core=31C Load=22% F6=2730000\
[\[STATE\]]{style="color:#6ad4ff"} ACTIVE → LIGHT (Skin=39C load=12%)\
[\[09:01:43\]]{style="color:#8c9a86"} LIGHT Skin=37C Core=41C
freq_cap=1700000
:::

Tail with:
`su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`
:::

::: section
::: section-header
[06 --- Installation]{.label}

## Flash & forget
:::

-   Confirm you are on **ArtisanROM Quant** with **KernelSU-Next**
    installed and root granted.
-   Download **PrimeThermal-vY.1-ArtisanROM.zip** (build from fork).
-   Open KernelSU app → **Modules** → tap **➕** → select the ZIP file.
-   Wait for installation → **Reboot**.
-   After reboot, verify log:
    `su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'`

Uninstall: disable / remove module in KernelSU → reboot. All sysfs
changes are volatile.
:::

::: credit-glossy
::: {style="font-family:var(--mono);font-size:18px;font-weight:700;margin-bottom:4px;"}
PrimeThermal v1.1-OneUI
:::

::: {style="font-size:12px;color:var(--text-muted);margin-bottom:18px;"}
by
[Prime1337](https://github.com/igoraotel-a11y/PrimeThermal){style="color:var(--green-primary);"}
· original thermal state machine & dual-sensor logic
:::

This ArtisanROM fork preserves upstream credit while adapting sysfs
paths, governor handling, and backlight detection for the S10+ on
upstreamed Exynos 9820 kernel. All core adaptive logic remains
attributed to Prime1337.

::: credit-links
[↗ Upstream
Repo](https://github.com/igoraotel-a11y/PrimeThermal){.credit-link} [↗
Telegram](https://t.me/PrimeThermal){.credit-link}
:::

::: {style="margin-top: 28px; border-top:1px solid var(--border-subtle); padding-top: 20px;"}
::: {style="font-family:var(--mono); font-size:11px; color: var(--text-dim);"}
Additional thanks: ArtisanROM, Android-Artisan (kernel), KernelSU-Next,
CruelKernel, UN1CA
:::
:::
:::

::: disclaimer-box
**⚠️ DISCLAIMER**\
This module modifies CPU frequency limits and schedutil parameters in
real time. All changes are reset after reboot. Use at your own risk. Not
affiliated with Samsung, ArtisanROM or original PrimeThermal. Monitor
thermals during first usage.
:::

::: footer
<div>

PrimeThermal vY.1-ArtisanROM · Fork for SM-G975F · Exynos 9820\
OneUI 8 / Android 16 · KernelSU-Next

</div>

<div>

GPL-3.0 · Upstream: igoraotel-a11y/PrimeThermal

</div>
:::
:::
