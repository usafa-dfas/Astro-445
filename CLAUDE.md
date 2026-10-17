# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Interactive lecture apps for AstroEngr 445 (spacecraft attitude dynamics), hosted on GitHub Pages from `main` / root (`.nojekyll` disables Jekyll). There is no build, package manager, linter, or test suite: every app is one self-contained `index.html` with inline CSS and JS.

- Root `index.html` is the menu. Each app is a card (`<a class="card">`) linking to its folder.
- Each app lives in `<app-name>/index.html` (`polhode-explorer`, `spinning-top-explorer`, `misaligned-burn-simulator`).

## Running

Open the file in a browser, or serve the repo root to test relative links: `python3 -m http.server 8000` and visit `http://localhost:8000/`. Apps need internet access, because Three.js and fonts come from CDNs.

To check something by hand, use the debug handle each app exposes in the console: `window.__polhode`, `window.__top`, `window.__burn`. Depending on the app, it holds the state object `S`, the integrator state `Y`, `rebuild`, `applyPreset`, `advance`, analysis results, and history buffers. Use it to drive the sim and check invariants, for example from Playwright, which has Chromium preinstalled here.

## Adding a lesson app

1. Create `<name>/index.html`.
2. Copy an `<a class="card">` block in the root `index.html` and update its href, topic, title, description and `.eqn` line.

## Shared app architecture

The three apps were written to one template. When you add or change an app, follow the same structure and conventions. The JS sits in a single IIFE, split into `/* ==== */` banner sections in this order: Utilities → Physics → State → 3D scene → Time-history plot (2D canvas) → Readouts → Rebuild pipeline → Inputs → Boot.

- **Dependencies:** Three.js pinned at `three@0.147.0` (the global `THREE` build plus `examples/js/controls/OrbitControls.js`) from jsDelivr. Fonts are Barlow Semi Condensed (UI), STIX Two Text (math) and IBM Plex Mono (numbers) from Google Fonts. Keep the same version pins across apps.
- **Theming:** colors are CSS custom properties on `:root`, with a dark set under `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) }` and again under `:root[data-theme="dark"]`, plus a `--scheme` variable. The theme button toggles `data-theme`. JS reads the colors via `readColors()`, which lists the variable names, and `applyTheme()` pushes them into Three.js materials. A `MutationObserver` on `data-theme` and the media-query listener call `applyTheme()`. A new color needs a light value, a dark value, and an entry in `readColors()`.
- **State and pipeline:** a single state object `S` holds the parameters and UI toggles. `rebuild()` recomputes the derived/analytic quantities, resets the integrator state `Y` (a `Float64Array`; quaternion + body rates in the top and burn apps, ω in polhode), clears the ring buffers and history, and refreshes the static and live readouts. Call it after any parameter change. Presets go through `applyPreset(name)`.
- **Integration:** fixed-step RK4 (`deriv`, `rk4`). `advance(dt)` substeps with a step size picked in `rebuild()` from the system's rates. The trails are ring buffers (`TRAIL_MAX`). The time history goes to preallocated `Float32Array` buffers (`HCAP`) at a sampling interval of its own.
- **Analytic side:** each app computes closed-form results next to the numerical sim: polhode classification and period via elliptic K, top turning points and nutation period, burn epicycloid and cones. These drive the readouts, regime cards and reference lines. Keep them consistent with the dynamics in `deriv`.
- **Render loop:** `frame()` via `requestAnimationFrame`. Each frame it advances by real dt × `S.speed`, updates the 3D scene, and redraws the 2D canvas plot. The readouts update at about 10 Hz.
- **Robustness:** `initGL()` runs in a try/catch. On failure `G = null` and a `.glfail` message appears, and the plots and analysis must still work. Guard 3D code with `if (G)` (or `HAS3D`). The apps respect `prefers-reduced-motion` and coarse pointers, and support fullscreen and keyboard shortcuts (space play/pause, r reset, f fit, 0/t/s views, o ortho).
- **Number formatting:** shared helpers `fx`, `fs`, `sci`, `fg` use a true minus sign `−` and superscript exponents. Use them rather than `toFixed` in readouts.
