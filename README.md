# Astronautical Engineering Lesson Apps

Self-contained interactive HTML apps for lecture. The menu is `index.html` at the repo root.

This repo is the private working copy. On every push to `main`, the workflow in `.github/workflows/publish.yml` copies the apps to the public repo [`usafa-dfas/astro-445-apps`](https://github.com/usafa-dfas/astro-445-apps), which serves them with GitHub Pages at https://usafa-dfas.github.io/astro-445-apps/. Make changes here, never in the public repo.

## Apps
| Folder | App |
|---|---|
| `attitude-parameter-explorer/` | Lessons 3–5 attitude parameters: DCM, axis/angle, Euler angles, quaternion, linked |
| `gimbal-lock-explorer/` | Lesson 4 Euler-angle singularities: three-gimbal mechanism, slews past gimbal lock |
| `polhode-explorer/` | Torque-free rigid body: energy/momentum ellipsoids, angular velocity, polhode, and an inertial view of a box with the same inertias |
| `attitude-sensor-tour/` | Lesson 22 sensors: sun sensor, Earth horizon sensor, magnetometer, star tracker, fiber optic, ring laser and MEMS gyros, accelerometer; what each measures and leaves unknown, and a sensor-suite builder |
| `star-tracker-explorer/` | Lesson 22 attitude determination: Wahba's problem and Davenport's q-method with real stars, pointing vs roll accuracy, App. A sun sensor and magnetometer, gyro drift and star fixes |
| `attitude-actuator-explorer/` | Lesson 22 actuators: one slew with reaction wheels, CMGs, thrusters and torque rods side by side; saturation and dumping, wheel failure, CMG singularity, thruster limit cycle, rods and the field direction |
| `spinning-top-explorer/` | Lesson 23 spinning top: precession, nutation, turning points, Appendix A gyroscope |
| `misaligned-burn-simulator/` | Lesson 24 misaligned burn: bounded rates, epicycloid, impulse and pulse torques |
| `nutation-damping-explorer/` | Lesson 25 damping: no damper, −bω torque and App. B rotor damper side by side; oblate vs prolate |
| `gyrostat-explorer/` | Lesson 26 gyrostats: wheel momentum and the unstable band, effective major axis with a damper, momentum bias, wheel spin-up |
| `momentum-precession-explorer/` | Lesson 27 momentum precession: a steady torque on a momentum-bias platform, precession and nutation as a cycloid, three wheel sizes against a pointing requirement, wheel sizing chart, outside vs internal damping |

## Adding a lesson
1. Create a folder, e.g. `nutation-demo/`, and put the app in `nutation-demo/index.html`.
2. Copy the `<a class="card">` block in the root `index.html`, and change the link and text.
3. `git add . && git commit -m "Add nutation demo" && git push` to `main`. The publish workflow copies it to the public repo, and Pages redeploys a minute or two later.

Apps load Three.js and fonts from public CDNs, so viewers need an internet connection.

The Star Tracker Explorer embeds star positions from the [HYG database](https://github.com/astronexus/HYG-Database) (v4.1, CC BY-SA 4.0): the stars brighter than magnitude 5, with close pairs merged.

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

### Publishing from your own computer
If Actions can't run (for example, while the organization's billing is locked), publish by hand with a script in `tools/`. It fetches `main` from GitHub, copies the same files the workflow would, and pushes one commit to the public repo. You don't need a local copy of either repo, and nothing on your computer is changed. It signs in to GitHub as you, so you need write access to `astro-445-apps`, and it needs [git](https://git-scm.com/downloads).

1. **Merge your changes into `main` first.** The script publishes `main` exactly as it is on GitHub.
2. **Download the script.** On GitHub, open `tools/publish.ps1` (Windows) or `tools/publish.sh` (Mac/Linux) and use "Download raw file".
3. **Run it from the folder you saved it to.**
   - Windows (PowerShell): `powershell -ExecutionPolicy Bypass -File publish.ps1`
   - Mac/Linux: `bash publish.sh`

   The first time, git opens a browser window to sign in to GitHub.
4. **Wait for Pages.** It refreshes the site a minute or two after the push.

Add `-DryRun` (Windows) or `--dry-run` (Mac/Linux) to see what would change without pushing. If git says it doesn't know who you are, run `git config --global user.name "Your Name"` and `git config --global user.email "you@example.com"` once.
