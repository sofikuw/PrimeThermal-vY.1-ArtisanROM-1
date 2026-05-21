# Changelog

## vY.1.2-ArtisanROM
> Fork of [PrimeThermal](https://github.com/igoraotel-a11y/PrimeThermal) by igoraotel-a11y (Prime1337).
> ArtisanROM fork by [sofikuw](https://github.com/sofikuw/PrimeThermal-vY.1-ArtisanROM-1).
> Additional inspiration: [Encore](https://github.com/Rem01Gaming/encore) (Apache-2.0) · [Gaming-X](https://github.com/JordanTweaks/Gaming-X-Magisk-Module) (GPL-3.0) · [SpeedCool](https://github.com/Llucs/SpeedCool-Magisk-Module)

### Added
- **Encore gamelist** — 530+ game packages merged into `GAMING_PACKAGES` (was 15). Covers HoYoverse, Tencent, NetEase, Bandai Namco, emulators, rhythm games, and more.
- **`scaling_min_freq` floors in GAMING** — locks each cluster's minimum frequency to `GAMING_MIN_FLOOR_PCT`% of stock max OPP during GAMING state. Prevents schedutil from drooping to low OPPs between game frames, eliminating inter-frame spike stutter on Exynos 9820. Resets to `cpuinfo_min_freq` in all other states. Default: 50%.
- **SurfaceFlinger latency tweaks** — on GAMING entry writes `debug.sf.disable_backpressure=1`, `debug.sf.latch_unsignaled=1`, and `early_phase_offset_ns=500000`. Reduces display pipeline backpressure and cuts ~1 vsync of touch-to-frame latency. Resets on GAMING exit. Toggle: `ENABLE_SF_TWEAKS`.
- **I/O scheduler tuning** — GAMING/ACTIVE: `deadline` scheduler + `nr_requests 512` for low latency. IDLE/POWERSAVE: `cfq` + `nr_requests 128` for fair throughput. Applied to all block devices. Toggle: `ENABLE_IO_TUNING`.
- **`sched_boost` (Samsung EAS)** — writes `1` to `/proc/sys/kernel/sched_boost` on GAMING entry; `0` on exit. Hints EAS to pack tasks onto big cores. `safe_write`-guarded; silently skipped if node absent. Toggle: `ENABLE_SCHED_BOOST`.
- **Android Game Manager API** — on GAMING entry detects the foreground package and calls `cmd game set --mode 2 <pkg>` (Android 12+ performance profile). Resets to mode 0 on exit. Toggle: `ENABLE_GAME_CMD`.
- **`vm.dirty_ratio` / `vm.vfs_cache_pressure` per state** — GAMING: `dirty_ratio=40`, `dirty_bg=20`, `cache_pressure=50` (more writes buffered, VFS cache warm). IDLE: `dirty_ratio=20`, `cache_pressure=100`.
- **`swappiness=1` in GAMING** — was 10. With 8 GB RAM, near-zero swappiness keeps game assets fully resident.
- **Bootloop safety guard** — checks for `boot_ok` flag on startup. If absent (previous boot crashed before first loop tick), forces `POWERSAVE` for ~120 s then restores configured `MODE`. `boot_ok` is written after tick 1, removed on clean SIGTERM.
- **S10 series support** — module now targets all three S10 Exynos 9820 variants: SM-G970F (S10e / beyond0lte), SM-G973F (S10 / beyond1lte), SM-G975F (S10+ / beyond2lte). Device is detected at startup and logged. All variants share the same cpufreq topology and thermal zone layout so no per-device branching is required.
- **WebUI** (`webroot/index.html`) — MMRL/KSU-Next module card UI with: live state badge + temperatures, mode toggle, per-feature toggles, min-freq floor slider, live log tail (auto-refresh 10 s), gamelist editor with add/remove/save. Fixed KSU-Next exec bridge: callbacks are now registered as named global functions (required by Android JavascriptInterface — anonymous function references were silently dropped).
- **`BURST_THRESH` in `config.sh`** — was hardcoded in `service.sh`. Now user-configurable without editing the daemon.
- **`on_gaming_exit()` hook** — centralises all GAMING teardown (Game Manager reset, etc.) regardless of why GAMING was exited (hard abort, package change, screen off).

### Changed
- Log line format updated to include `min=` frequency columns alongside `max=`.
- Startup log now prints all feature toggle states for easier debugging.
- `apply_tweaks` is now fully self-contained per state — each case handles schedutil, swappiness, vm, sched_boost, I/O, and SF tweaks in one place.

---

## vY.1.1.1-ArtisanROM
- BURST threshold lowered 60% → 25% (configurable).
- IDLE exit is instant — bypasses 15 s debounce for scroll/swipe responsiveness.
- IDLE BIG cap raised 1200 MHz → 1600 MHz.
- IDLE `down_rate_limit_us` 8000 µs → 4000 µs.
- LIGHT → any upgrade also instant (was IDLE-only).

## vY.1.1-ArtisanROM
- GAMING mode, POWERSAVE mode, BURST detection, WebUI scaffolding, hard abort, mode-specific HC triggers, raised IDLE/LIGHT floors.
- `schedutil up_rate_limit_us = 500 µs` on all modes.
- `/proc/uptime` debounce timer, unconditional log rotation.
- HH:MM:SS timestamps.

## vY.1-ArtisanROM
- Initial fork from PrimeThermal v1.1-OneUI (Prime1337).
- Rebuilt for SM-G975F / ArtisanROM / KernelSU-Next / ArtisanKRNL Linux 5.x.
- Exynos 9820 cpufreq topology: pol0=LITTLE, pol4=MID, pol6=BIG.
- Removed compact_memory, cpu_boost, KGSL writes (absent on Exynos/Linux 5.x).
- Added CHARGING state, battery fallback thermal sensor.
