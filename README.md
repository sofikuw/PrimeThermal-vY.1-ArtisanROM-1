# PrimeThermal — ArtisanROM Fork

**ACTIVE — Magisk / KernelSU-Next**  
**vY.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820**

Adaptive thermal & CPU frequency manager for Galaxy S10+ (ArtisanROM Quant / OneUI 8).  
Real-time skin & core sensing, five automatic power modes, and progressive frequency caps to prevent overheating without killing performance.

- ArtisanROM Quant
- KernelSU-Next
- Exynos 9820
- SM-G975F
- SELinux Enforcing
- Sysfs-only

---

## 01 — Core: Architecture & Sensing

Background shell loop (`service.sh`) triggers every 5 seconds. It reads thermal zones (skin/CPU clusters) and CPU load average, then applies the optimal mode via sysfs. Mode changes are debounced (15s cooldown) to prevent rapid flickering.

### // Thermal zones (Exynos 9820)

**Skin sensor** (thermal_zone5) measures surface temperature — primary throttling trigger.  
**Core sensors** (zones 0,1,2) catch sudden compute spikes. The module uses the maximum of both and applies progressive caps.

### // CPU load & debounce

Three consecutive readings from `/proc/stat` are averaged. Load percentage, combined with temperature and charging state, determines final mode.

---

## 02 — Modes: Five Adaptive States

| Mode | Trigger | Frequencies & Tuning |
|------|---------|----------------------|
| **POCKET** | screen off / backlight = 0 | LITTLE 600 MHz, MID 600 MHz, BIG 600 MHz, swappiness=100 |
| **IDLE** | screen on, low temp, load <15% | LITTLE 1.0 GHz, MID 900 MHz, BIG 700 MHz, swappiness=60 |
| **LIGHT** | skin ≥37°C or load 15–40% | 1.3GHz / 1.5GHz / 1.7GHz, swappiness=60 |
| **ACTIVE** | skin ≥41°C or load ≥40% | dynamic caps (see heat table), swappiness=10 |
| **CHARGING** | charging + skin ≥38°C | 975/1157/1092 MHz, swappiness=10 |

### ▼ ACTIVE mode thermal steps (progressive)

---text
# sustained heat ≥ 2 cycles (10+ sec)
T ≥ 44°C  →  50% OPP  (975 / 1157 / 1365 MHz)
T ≥ 42°C  →  65% OPP  (1267 / 1504 / 1774 MHz)
T ≥ 40°C  →  80% OPP  (1560 / 1851 / 2184 MHz)
T < 40°C  →  full OPP (1950 / 2314 / 2730 MHz)
---

---

03 — Sysfs Interface: Nodes Read & Written

Path Description
/sys/class/thermal/thermal_zone5/temp Skin / PCB temp (primary decision)
/sys/class/thermal/thermal_zone6/temp Battery temperature fallback
/sys/class/thermal/thermal_zone{0,1,2}/temp CPU clusters (LITTLE, MID, BIG)
/sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq Hard frequency cap (cluster 0/4/6)
/sys/.../schedutil/up_rate_limit_us Frequency ramp-up aggressiveness
/sys/class/power_supply/battery/status Charging detection (status=Charging)
/sys/class/backlight/*/brightness Screen state (probes panel0 / s6e3ha9 etc.)
/proc/sys/vm/swappiness Swap tendency — raised in idle/pocket modes

---

04 — Fork Changes: ArtisanROM Adaptations

Area Upstream assumption ArtisanROM reality & fix
compact_memory Written each mode switch ArtisanKRNL (Linux 5.x+) removed /proc/sys/vm/compact_memory – node completely dropped from fork.
Governor detection Probed interactive/ondemand/schedutil Upstreamed kernel ships schedutil only; interactive/ondemand removed. Simplified to schedutil exclusive, added rate_limit_us fallback.
Thermal zone probing Probed zones 0–9 (assumed HAL renumbering) ArtisanROM registers zones directly from DTS: zone5=skin, zone6=battery, zones0-2=CPU clusters. Hardcoded – probing removed.
Screen detection backlight → SurfaceFlinger grep → dumpsys SF format unreliable; now uses backlight node (probes panel0-backlight, s6e3ha9, s6e3hc2) + dumpsys power fallback.
Backlight path Only panel0-backlight S10+ uses s6e3ha9 AMOLED driver; module auto-probes 4 panel paths and logs result.
Log location /data/local/tmp/ KernelSU-Next → preferred path /data/adb/modules/PrimeThermalArtisanROM/ (avoids SELinux strict context).
Samsung thermal daemon Potential sec_ts conflict ArtisanROM is heavily DeKnoxed; Samsung thermal daemon stripped – sysfs writes uncontested.

---

05 — Logging: Real‑time Monitoring

Log rotated at 1000 lines.
Primary path: /data/adb/modules/PrimeThermalArtisanROM/thermal.log
Fallback path: /data/local/tmp/s10_thermal.log

Log sample

```text
[INIT] PrimeThermal vY.1 started PID=1337
[TWEAKS] PERF applied
[09:00:06] ACTIVE Skin=28C Core=31C Load=22% F6=2730000
[STATE] ACTIVE → LIGHT (Skin=39C load=12%)
[09:01:43] LIGHT  Skin=37C Core=41C freq_cap=1700000
```

Tail log in real-time:

```bash
su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'
```

---

06 — Installation: Flash & Forget

1. Confirm you are on ArtisanROM Quant with KernelSU-Next installed and root granted.
2. Download PrimeThermal-vY.1-ArtisanROM.zip (build from fork).
3. Open KernelSU app → Modules → tap ➕ → select the ZIP file.
4. Wait for installation → Reboot.
5. After reboot, verify log:

```bash
su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'
```

Uninstall: Disable or remove the module in KernelSU → reboot. All sysfs changes are volatile.

---

Credits

PrimeThermal v1.1-OneUI
by Prime1337 · original thermal state machine & dual-sensor logic

This ArtisanROM fork preserves upstream credit while adapting sysfs paths, governor handling, and backlight detection for the S10+ on upstreamed Exynos 9820 kernel. All core adaptive logic remains attributed to Prime1337.

Links:

· Upstream Repository (igoraotel-a11y/PrimeThermal)
· PrimeThermal Telegram Channel

Additional thanks:

· ArtisanROM
· Android-Artisan (kernel)
· KernelSU-Next
· CruelKernel
· UN1CA / KnoxPatch

---

⚠️ Disclaimer

This module modifies CPU frequency limits and schedutil parameters in real time. All changes are reset after reboot. Use at your own risk. Not affiliated with Samsung, ArtisanROM or original PrimeThermal. Monitor thermals during first usage.

---

PrimeThermal vY.1-ArtisanROM · Fork for SM-G975F · Exynos 9820
OneUI 8 / Android 16 · KernelSU-Next

License: GPL-3.0
Upstream: igoraotel-a11y/PrimeThermal

