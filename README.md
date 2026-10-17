# Astronautical Engineering Lesson Apps

Self-contained interactive HTML apps for lecture. Hosted with GitHub Pages; the menu is `index.html` at the repo root.

## Apps
| Folder | App |
|---|---|
| `polhode-explorer/` | Torque-free rigid body: energy/momentum ellipsoids, angular velocity, polhode |
| `spinning-top-explorer/` | Lesson 23 spinning top: precession, nutation, turning points, Appendix A gyroscope |
| `misaligned-burn-simulator/` | Lesson 24 misaligned burn: bounded rates, epicycloid, impulse and pulse torques |

## Adding a lesson
1. Create a folder, e.g. `nutation-demo/`, and put the app in `nutation-demo/index.html`.
2. Copy the `<a class="card">` block in the root `index.html`, and change the link and text.
3. `git add . && git commit -m "Add nutation demo" && git push`. Pages redeploys in about a minute.

Apps load Three.js and fonts from public CDNs, so viewers need an internet connection.

## Publishing
Settings → Pages → Deploy from a branch → `main` / root.
