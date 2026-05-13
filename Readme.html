<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
  <title>PrimeThermal · ArtisanROM Fork | S10+ Exynos 9820</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    /* ===== DARK CYBER / TERMINAL THEME ===== */
    :root {
      --bg-deep: #0a0c0a;
      --bg-surface: #101412;
      --bg-elevated: #181e1a;
      --border-subtle: #252e28;
      --border-accent: #3e5a45;
      --green-primary: #4aff7a;
      --green-dim: #2a8c4a;
      --green-glow: rgba(74, 255, 122, 0.12);
      --amber: #f5b342;
      --amber-dim: #8a5a1a;
      --red: #ff5f5f;
      --blue: #6ad4ff;
      --text-body: #d4e0d0;
      --text-muted: #8c9a86;
      --text-dim: #4a5546;
      --mono: 'SF Mono', 'IBM Plex Mono', 'Fira Code', monospace;
      --sans: 'Inter', 'IBM Plex Sans', system-ui, -apple-system, sans-serif;
    }

    body {
      background-color: var(--bg-deep);
      color: var(--text-body);
      font-family: var(--sans);
      font-size: 15px;
      line-height: 1.65;
      padding: 0 0 80px 0;
    }

    /* scanline / noise effect */
    body::before {
      content: "";
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-image: repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.08) 0px, rgba(0, 0, 0, 0.08) 2px, transparent 2px, transparent 6px);
      pointer-events: none;
      z-index: 0;
    }

    .container {
      max-width: 960px;
      margin: 0 auto;
      padding: 0 24px;
      position: relative;
      z-index: 2;
    }

    /* ===== HEADER / HERO ===== */
    .hero {
      padding: 56px 0 40px;
      border-bottom: 1px solid var(--border-subtle);
      margin-bottom: 8px;
    }

    .badge {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      background: var(--green-glow);
      border: 1px solid var(--green-dim);
      padding: 6px 16px;
      font-family: var(--mono);
      font-size: 11px;
      font-weight: 500;
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--green-primary);
      margin-bottom: 28px;
      border-radius: 32px;
      backdrop-filter: blur(2px);
    }

    .badge::before {
      content: "●";
      font-size: 10px;
      color: var(--green-primary);
      animation: pulse 2s ease-in-out infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 0.5; text-shadow: none; }
      50% { opacity: 1; text-shadow: 0 0 6px var(--green-primary); }
    }

    h1 {
      font-family: var(--mono);
      font-size: clamp(36px, 7vw, 56px);
      font-weight: 700;
      letter-spacing: -0.02em;
      line-height: 1.1;
      color: white;
    }

    h1 span {
      color: var(--green-primary);
    }

    .hero-sub {
      font-family: var(--mono);
      font-size: 13px;
      color: var(--text-muted);
      margin-top: 12px;
      margin-bottom: 20px;
      border-left: 2px solid var(--green-dim);
      padding-left: 18px;
    }

    .hero-desc {
      max-width: 620px;
      font-size: 16px;
      color: var(--text-body);
      margin: 20px 0 28px;
    }

    .tag-strip {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-top: 8px;
    }

    .tag {
      font-family: var(--mono);
      font-size: 10px;
      font-weight: 500;
      padding: 4px 10px;
      background: var(--bg-surface);
      border: 1px solid var(--border-subtle);
      color: var(--text-muted);
      border-radius: 20px;
    }

    .tag.highlight {
      border-color: var(--green-dim);
      color: var(--green-primary);
      background: rgba(74, 255, 122, 0.05);
    }

    .tag.warning {
      border-color: var(--amber-dim);
      color: var(--amber);
    }

    /* ===== SECTION STYLES ===== */
    section {
      margin: 48px 0 24px;
    }

    .section-header {
      display: flex;
      align-items: center;
      gap: 16px;
      margin-bottom: 28px;
    }

    .section-header .label {
      font-family: var(--mono);
      font-size: 11px;
      font-weight: 600;
      letter-spacing: 0.2em;
      color: var(--text-muted);
      background: var(--bg-surface);
      padding: 4px 12px;
      border-radius: 40px;
      border: 1px solid var(--border-subtle);
    }

    .section-header h2 {
      font-family: var(--mono);
      font-size: 22px;
      font-weight: 600;
      color: white;
      letter-spacing: -0.3px;
    }

    h3 {
      font-family: var(--mono);
      font-size: 14px;
      font-weight: 600;
      color: var(--green-primary);
      margin: 32px 0 12px;
      letter-spacing: 0.02em;
    }

    /* mode cards grid (fixed visuals) */
    .mode-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
      gap: 1px;
      background: var(--border-subtle);
      border: 1px solid var(--border-subtle);
      margin: 28px 0;
      border-radius: 12px;
      overflow: hidden;
    }

    .mode-card {
      background: var(--bg-surface);
      padding: 20px 16px;
      transition: all 0.15s;
    }

    .mode-card:hover {
      background: var(--bg-elevated);
    }

    .mode-name {
      font-family: var(--mono);
      font-weight: 700;
      font-size: 12px;
      letter-spacing: 0.1em;
      margin-bottom: 12px;
    }

    .mode-card.pocket .mode-name { color: var(--blue); }
    .mode-card.idle .mode-name { color: var(--green-primary); }
    .mode-card.light .mode-name { color: #b8f27a; }
    .mode-card.active .mode-name { color: var(--amber); }
    .mode-card.charging .mode-name { color: var(--red); }

    .mode-trigger {
      font-size: 11px;
      color: var(--text-muted);
      line-height: 1.45;
      margin-bottom: 18px;
      border-left: 1px solid var(--border-accent);
      padding-left: 10px;
    }

    .mode-freqs {
      font-family: var(--mono);
      font-size: 10px;
      color: var(--text-dim);
      border-top: 1px solid var(--border-subtle);
      padding-top: 12px;
      line-height: 1.7;
    }

    /* sysfs table clean */
    .sysfs-card {
      background: var(--bg-surface);
      border-left: 3px solid var(--green-dim);
      border-radius: 12px;
      padding: 6px 0;
      margin: 24px 0;
    }

    .sysfs-row {
      display: grid;
      grid-template-columns: 300px 1fr;
      gap: 20px;
      padding: 14px 20px;
      border-bottom: 1px solid var(--border-subtle);
      align-items: baseline;
    }

    .sysfs-row:last-child {
      border-bottom: none;
    }

    .sysfs-path {
      font-family: var(--mono);
      font-size: 11px;
      color: var(--blue);
      word-break: break-word;
    }

    .sysfs-desc {
      font-size: 12px;
      color: var(--text-muted);
      line-height: 1.5;
    }

    /* changelog table */
    .change-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
      margin: 28px 0;
      background: var(--bg-surface);
      border-radius: 14px;
      overflow: hidden;
      border: 1px solid var(--border-subtle);
    }

    .change-table th {
      text-align: left;
      font-family: var(--mono);
      font-size: 10px;
      letter-spacing: 0.1em;
      color: var(--text-muted);
      background: var(--bg-elevated);
      padding: 14px 18px;
      border-bottom: 1px solid var(--border-accent);
    }

    .change-table td {
      padding: 14px 18px;
      border-bottom: 1px solid var(--border-subtle);
      vertical-align: top;
      color: var(--text-body);
    }

    .change-table tr:last-child td {
      border-bottom: none;
    }

    .change-table td:first-child {
      font-family: var(--mono);
      font-weight: 500;
      color: var(--green-primary);
      width: 140px;
    }

    /* code blocks */
    pre {
      background: #0b0f0c;
      border: 1px solid var(--border-subtle);
      border-radius: 16px;
      padding: 18px 22px;
      font-family: var(--mono);
      font-size: 12px;
      overflow-x: auto;
      line-height: 1.6;
      margin: 20px 0;
    }

    code {
      font-family: var(--mono);
      background: var(--bg-elevated);
      padding: 2px 8px;
      border-radius: 20px;
      font-size: 11px;
      border: 1px solid var(--border-subtle);
      color: var(--green-primary);
    }

    .log-sample {
      background: #0a0e0b;
      border-radius: 16px;
      padding: 20px;
      font-family: var(--mono);
      font-size: 11px;
      line-height: 1.9;
      border: 1px solid var(--border-accent);
      overflow-x: auto;
    }

    .steps-list {
      list-style: none;
      counter-reset: step-counter;
      margin: 24px 0;
    }

    .steps-list li {
      counter-increment: step-counter;
      background: var(--bg-surface);
      margin-bottom: 10px;
      padding: 16px 20px 16px 56px;
      border-radius: 20px;
      border: 1px solid var(--border-subtle);
      position: relative;
      transition: background 0.1s;
      font-size: 14px;
    }

    .steps-list li:hover {
      background: var(--bg-elevated);
    }

    .steps-list li::before {
      content: counter(step-counter, decimal-leading-zero);
      position: absolute;
      left: 18px;
      top: 16px;
      font-family: var(--mono);
      font-weight: 700;
      font-size: 12px;
      color: var(--green-primary);
      background: var(--green-glow);
      padding: 0 6px;
      border-radius: 24px;
    }

    .credit-glossy {
      background: var(--bg-surface);
      border-radius: 20px;
      padding: 28px 32px;
      margin: 32px 0;
      border: 1px solid var(--border-accent);
      position: relative;
    }

    .credit-glossy::after {
      content: "// UPSTREAM";
      position: absolute;
      top: 24px;
      right: 28px;
      font-family: var(--mono);
      font-size: 10px;
      color: var(--text-muted);
      letter-spacing: 0.1em;
    }

    .credit-links {
      display: flex;
      gap: 14px;
      margin-top: 20px;
      flex-wrap: wrap;
    }

    .credit-link {
      font-family: var(--mono);
      font-size: 11px;
      border: 1px solid var(--green-dim);
      padding: 8px 18px;
      border-radius: 60px;
      color: var(--green-primary);
      text-decoration: none;
      transition: 0.1s;
    }

    .credit-link:hover {
      background: var(--green-glow);
      border-color: var(--green-primary);
    }

    .disclaimer-box {
      margin: 48px 0 32px;
      background: rgba(245, 179, 66, 0.05);
      border-left: 4px solid var(--amber);
      padding: 22px 28px;
      border-radius: 24px;
      font-size: 12px;
      font-family: var(--mono);
      color: var(--amber);
    }

    .footer {
      margin-top: 50px;
      padding-top: 28px;
      border-top: 1px solid var(--border-subtle);
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 20px;
      font-size: 11px;
      color: var(--text-muted);
      font-family: var(--mono);
    }

    @media (max-width: 700px) {
      .sysfs-row {
        grid-template-columns: 1fr;
        gap: 6px;
      }
      .change-table td:first-child {
        width: auto;
      }
      .mode-grid {
        grid-template-columns: 1fr 1fr;
      }
    }
  </style>
</head>
<body>
<div class="container">
  <!-- Hero -->
  <div class="hero">
    <div class="badge">ACTIVE — Magisk / KernelSU-Next</div>
    <h1>Prime<span>Thermal</span></h1>
    <div class="hero-sub">vY.1-ArtisanROM · SM-G975F beyond2lte · Exynos 9820</div>
    <p class="hero-desc">
      Adaptive thermal & CPU frequency manager for Galaxy S10+ (ArtisanROM Quant / OneUI 8).
      Real-time skin & core sensing, five automatic power modes, and progressive frequency caps
      to prevent overheating without killing performance.
    </p>
    <div class="tag-strip">
      <span class="tag highlight">ArtisanROM Quant</span>
      <span class="tag highlight">KernelSU-Next</span>
      <span class="tag">Exynos 9820</span>
      <span class="tag">SM-G975F</span>
      <span class="tag warning">SELinux Enforcing</span>
      <span class="tag">Sysfs-only</span>
    </div>
  </div>

  <!-- How it works -->
  <section>
    <div class="section-header">
      <span class="label">01 — Core</span>
      <h2>Architecture & sensing</h2>
    </div>
    <p>Background shell loop (<code>service.sh</code>) triggers every 5 seconds. It reads thermal zones (skin/CPU clusters) and CPU load average, then applies the optimal mode via sysfs. Mode changes are debounced (15s cooldown) to prevent rapid flickering.</p>
    <h3>// Thermal zones (Exynos 9820)</h3>
    <p><strong>Skin sensor</strong> (thermal_zone5) measures surface temperature — primary throttling trigger. <strong>Core sensors</strong> (zones 0,1,2) catch sudden compute spikes. The module uses the maximum of both and applies progressive caps.</p>
    <h3>// CPU load & debounce</h3>
    <p>Three consecutive readings from <code>/proc/stat</code> are averaged. Load percentage, combined with temperature and charging state, determines final mode.</p>
  </section>

  <!-- five adaptive modes -->
  <section>
    <div class="section-header">
      <span class="label">02 — Modes</span>
      <h2>Five adaptive states</h2>
    </div>
    <div class="mode-grid">
      <div class="mode-card pocket"><div class="mode-name">POCKET</div><div class="mode-trigger">screen off / backlight = 0</div><div class="mode-freqs">LITTLE 600 MHz<br>MID 600 MHz<br>BIG 600 MHz<br>swappiness=100</div></div>
      <div class="mode-card idle"><div class="mode-name">IDLE</div><div class="mode-trigger">screen on · low temp · load &lt;15%</div><div class="mode-freqs">LITTLE 1.0 GHz<br>MID 900 MHz<br>BIG 700 MHz<br>swappiness=60</div></div>
      <div class="mode-card light"><div class="mode-name">LIGHT</div><div class="mode-trigger">skin ≥37°C or load 15–40%</div><div class="mode-freqs">1.3GHz / 1.5GHz / 1.7GHz<br>swappiness=60</div></div>
      <div class="mode-card active"><div class="mode-name">ACTIVE</div><div class="mode-trigger">skin ≥41°C or load ≥40%</div><div class="mode-freqs">dynamic caps (see heat table)<br>swappiness=10</div></div>
      <div class="mode-card charging"><div class="mode-name">CHARGING</div><div class="mode-trigger">charging + skin ≥38°C</div><div class="mode-freqs">975/1157/1092 MHz<br>swappiness=10</div></div>
    </div>
    <h3>▼ ACTIVE mode thermal steps (progressive)</h3>
    <pre><span style="color:#6ad4ff"># sustained heat ≥ 2 cycles (10+ sec)</span>
T ≥ 44°C  →  50% OPP  (975 / 1157 / 1365 MHz)
T ≥ 42°C  →  65% OPP  (1267 / 1504 / 1774 MHz)
T ≥ 40°C  →  80% OPP  (1560 / 1851 / 2184 MHz)
T < 40°C   →  full OPP (1950 / 2314 / 2730 MHz)</pre>
  </section>

  <!-- SYSFS MAP (fixed visual) -->
  <section>
    <div class="section-header">
      <span class="label">03 — Sysfs Interface</span>
      <h2>Nodes read & written</h2>
    </div>
    <div class="sysfs-card">
      <div class="sysfs-row"><span class="sysfs-path">/sys/class/thermal/thermal_zone5/temp</span><span class="sysfs-desc">Skin / PCB temp (primary decision)</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/class/thermal/thermal_zone6/temp</span><span class="sysfs-desc">Battery temperature fallback</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/class/thermal/thermal_zone{0,1,2}/temp</span><span class="sysfs-desc">CPU clusters (LITTLE, MID, BIG)</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq</span><span class="sysfs-desc">Hard frequency cap (cluster 0/4/6)</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/.../schedutil/up_rate_limit_us</span><span class="sysfs-desc">Frequency ramp-up aggressiveness</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/class/power_supply/battery/status</span><span class="sysfs-desc">Charging detection (status=Charging)</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/sys/class/backlight/*/brightness</span><span class="sysfs-desc">Screen state (probes panel0 / s6e3ha9 etc.)</span></div>
      <div class="sysfs-row"><span class="sysfs-path">/proc/sys/vm/swappiness</span><span class="sysfs-desc">Swap tendency — raised in idle/pocket modes</span></div>
    </div>
  </section>

  <!-- Fork changes table (fixed, no cut-off) -->
  <section>
    <div class="section-header">
      <span class="label">04 — Fork changes</span>
      <h2>ArtisanROM adaptations</h2>
    </div>
    <table class="change-table">
      <thead><tr><th>Area</th><th>Upstream assumption</th><th>ArtisanROM reality & fix</th></tr></thead>
      <tbody>
        <tr><td>compact_memory</td><td>Written each mode switch</td><td>ArtisanKRNL (Linux 5.x+) removed /proc/sys/vm/compact_memory – node completely dropped from fork.</td></tr>
        <tr><td>Governor detection</td><td>Probed interactive/ondemand/schedutil</td><td>Upstreamed kernel ships schedutil only; interactive/ondemand removed. Simplified to schedutil exclusive, added rate_limit_us fallback.</td></tr>
        <tr><td>Thermal zone probing</td><td>Probed zones 0–9 (assumed HAL renumbering)</td><td>ArtisanROM registers zones directly from DTS: zone5=skin, zone6=battery, zones0-2=CPU clusters. Hardcoded – probing removed.</td></tr>
        <tr><td>Screen detection</td><td>backlight → SurfaceFlinger grep → dumpsys</td><td>SF format unreliable; now uses backlight node (probes panel0-backlight, s6e3ha9, s6e3hc2) + dumpsys power fallback.</td></tr>
        <tr><td>Backlight path</td><td>Only panel0-backlight</td><td>S10+ uses s6e3ha9 AMOLED driver; module auto-probes 4 panel paths and logs result.</td></tr>
        <tr><td>Log location</td><td>/data/local/tmp/</td><td>KernelSU-Next → preferred path /data/adb/modules/PrimeThermalArtisanROM/ (avoids SELinux strict context).</td></tr>
        <tr><td>Samsung thermal daemon</td><td>Potential sec_ts conflict</td><td>ArtisanROM is heavily DeKnoxed; Samsung thermal daemon stripped – sysfs writes uncontested.</td></tr>
      </tbody>
    </table>
  </section>

  <!-- logging + installation clean -->
  <section>
    <div class="section-header">
      <span class="label">05 — Logging</span>
      <h2>Real‑time monitoring</h2>
    </div>
    <p>Log rotated at 1000 lines. Path: <code>/data/adb/modules/PrimeThermalArtisanROM/thermal.log</code> (fallback <code>/data/local/tmp/s10_thermal.log</code>)</p>
    <div class="log-sample">
      <span style="color:#4aff7a">[INIT]</span> PrimeThermal vY.1 started PID=1337<br>
      <span style="color:#4aff7a">[TWEAKS]</span> PERF applied<br>
      <span style="color:#6ad4ff">[09:00:06]</span> <span style="color:#f5b342">ACTIVE</span> Skin=28C Core=31C Load=22% F6=2730000<br>
      <span style="color:#6ad4ff">[STATE]</span> ACTIVE → LIGHT (Skin=39C load=12%)<br>
      <span style="color:#8c9a86">[09:01:43]</span> LIGHT  Skin=37C Core=41C freq_cap=1700000
    </div>
    <p>Tail with: <code>su -c 'tail -f /data/adb/modules/PrimeThermalArtisanROM/thermal.log'</code></p>
  </section>

  <section>
    <div class="section-header">
      <span class="label">06 — Installation</span>
      <h2>Flash & forget</h2>
    </div>
    <ul class="steps-list">
      <li>Confirm you are on <strong>ArtisanROM Quant</strong> with <strong>KernelSU-Next</strong> installed and root granted.</li>
      <li>Download <strong>PrimeThermal-vY.1-ArtisanROM.zip</strong> (build from fork).</li>
      <li>Open KernelSU app → <strong>Modules</strong> → tap <strong>➕</strong> → select the ZIP file.</li>
      <li>Wait for installation → <strong>Reboot</strong>.</li>
      <li>After reboot, verify log: <code>su -c 'cat /data/adb/modules/PrimeThermalArtisanROM/thermal.log'</code></li>
    </ul>
    <p>Uninstall: disable / remove module in KernelSU → reboot. All sysfs changes are volatile.</p>
  </section>

<!-- credits -->
  <div class="credit-glossy">
    <div style="font-family:var(--mono);font-size:18px;font-weight:700;margin-bottom:4px;">PrimeThermal v1.1-OneUI</div>
    <div style="font-size:12px;color:var(--text-muted);margin-bottom:18px;">by <a href="https://github.com/igoraotel-a11y/PrimeThermal" style="color:var(--green-primary);">Prime1337</a> · original thermal state machine & dual-sensor logic</div>
    <p style="font-size:14px;">This ArtisanROM fork preserves upstream credit while adapting sysfs paths, governor handling, and backlight detection for the S10+ on upstreamed Exynos 9820 kernel. All core adaptive logic remains attributed to Prime1337.</p>
    <div class="credit-links">
      <a class="credit-link" href="https://github.com/igoraotel-a11y/PrimeThermal">↗ Upstream Repo</a>
      <a class="credit-link" href="https://t.me/PrimeThermal">↗ Telegram</a>
    </div>
    <div style="margin-top: 28px; border-top:1px solid var(--border-subtle); padding-top: 20px;">
      <div style="font-family:var(--mono); font-size:11px; color: var(--text-dim);">Additional thanks: ArtisanROM, Android-Artisan (kernel), KernelSU-Next, CruelKernel, UN1CA</div>
    </div>
  </div>

  <div class="disclaimer-box">
    <strong>⚠️ DISCLAIMER</strong><br>
    This module modifies CPU frequency limits and schedutil parameters in real time. All changes are reset after reboot. Use at your own risk. Not affiliated with Samsung, ArtisanROM or original PrimeThermal. Monitor thermals during first usage.
  </div>

  <div class="footer">
    <div>PrimeThermal vY.1-ArtisanROM · Fork for SM-G975F · Exynos 9820<br>OneUI 8 / Android 16 · KernelSU-Next</div>
    <div>GPL-3.0 · Upstream: igoraotel-a11y/PrimeThermal</div>
  </div>
</div>
</body>
</html>
