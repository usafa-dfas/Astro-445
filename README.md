# Astronautical Engineering Lesson Apps

Self-contained interactive HTML apps for lecture. The menu is `index.html` at the repo root.

This repo is the private working copy. On every push to `main`, the workflow in `.github/workflows/publish.yml` copies the apps to the public repo [`usafa-dfas/astro-445-apps`](https://github.com/usafa-dfas/astro-445-apps), which serves them with GitHub Pages at https://usafa-dfas.github.io/astro-445-apps/. Make changes here, never in the public repo.

## Apps
| Folder | App |
|---|---|
| `attitude-parameter-explorer/` | Lessons 3–5 attitude parameters: DCM, axis/angle, Euler angles, quaternion, linked |
| `gimbal-lock-explorer/` | Lesson 4 Euler-angle singularities: three-gimbal mechanism, slews past gimbal lock |
| `polhode-explorer/` | Torque-free rigid body: energy/momentum ellipsoids, angular velocity, polhode, and an inertial view of a box with the same inertias |
| `spinning-top-explorer/` | Lesson 23 spinning top: precession, nutation, turning points, Appendix A gyroscope |
| `misaligned-burn-simulator/` | Lesson 24 misaligned burn: bounded rates, epicycloid, impulse and pulse torques |
| `nutation-damping-explorer/` | Lesson 25 damping: no damper, −bω torque and App. B rotor damper side by side; oblate vs prolate |
| `gyrostat-explorer/` | Lesson 26 gyrostats: wheel momentum and the unstable band, effective major axis with a damper, momentum bias, wheel spin-up |

## Adding a lesson
1. Create a folder, e.g. `nutation-demo/`, and put the app in `nutation-demo/index.html`.
2. Copy the `<a class="card">` block in the root `index.html`, and change the link and text.
3. `git add . && git commit -m "Add nutation demo" && git push` to `main`. The publish workflow copies it to the public repo, and Pages redeploys a minute or two later.

Apps load Three.js and fonts from public CDNs, so viewers need an internet connection.

## Publishing
The workflow copies everything except `README.md`, `CLAUDE.md`, `.gitattributes` and the `.git`, `.github` and `.claude` folders, and deletes from the public repo anything deleted here. It also writes a short README into the public repo. Anyone can read the published apps' source in their browser; keeping this repo private hides only its history and the files above.

One-time setup:
1. **Create the public repo.** Create `usafa-dfas/astro-445-apps` as a public repo. It can start empty.
2. **Make a deploy key.** On your own computer run `ssh-keygen -t ed25519 -C "astro-445 publish" -f astro445_deploy -N ""`. This makes `astro445_deploy` (private) and `astro445_deploy.pub` (public).
3. **Give the public repo the public half.** In `astro-445-apps`, open Settings → Deploy keys → Add deploy key. Paste the contents of `astro445_deploy.pub` and tick **Allow write access**.
4. **Give this repo the private half.** In `Astro-445`, open Settings → Secrets and variables → Actions → New repository secret. Name it `PUBLIC_DEPLOY_KEY` and paste the whole contents of `astro445_deploy`, including the BEGIN and END lines. Then delete both key files from your computer.
5. **Run the first publish.** Push to `main`, or open Actions → "Publish apps to the public site" → Run workflow. Check that `astro-445-apps` now holds the apps.
6. **Turn on Pages for the public repo.** In `astro-445-apps`, open Settings → Pages → Deploy from a branch → `main` / root.
7. **Make this repo private.** In `Astro-445`, first turn off its Pages site (Settings → Pages), then open Settings → General → Danger Zone → Change visibility → Private. The old address https://usafa-dfas.github.io/Astro-445/ stops working; share the new one.

If the workflow fails, its log says why. The usual causes are a missing secret, a deploy key added without write access, or an organization policy that disables deploy keys or Actions on private repos.
