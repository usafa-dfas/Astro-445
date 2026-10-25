#!/usr/bin/env bash
# Publishes the lecture apps from the private Astro-445 repo to the public astro-445-apps repo.
# Mac and Linux counterpart of publish.ps1; see that file for details. Uses your own GitHub sign-in.
#   bash publish.sh            publish
#   bash publish.sh --dry-run  show what would change without pushing
# The same files are excluded as in .github/workflows/publish.yml. Keep the lists in step.
set -euo pipefail

SOURCE_REPO="${SOURCE_REPO:-https://github.com/usafa-dfas/Astro-445.git}"
PUBLIC_REPO="${PUBLIC_REPO:-https://github.com/usafa-dfas/astro-445-apps.git}"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

fail() { printf '\nPublish failed: %s\n' "$1" >&2; exit 1; }
command -v git >/dev/null || fail "git is not installed."
git config --get user.name >/dev/null && git config --get user.email >/dev/null ||
  fail 'git does not know who you are. Run: git config --global user.name "Your Name"; git config --global user.email "you@example.com"'

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Fetching the source repo (main)..."
git clone --quiet --depth 1 --branch main "$SOURCE_REPO" "$work/source"
sha="$(git -C "$work/source" rev-parse --short=7 HEAD)"

echo "Fetching the public repo..."
git clone --quiet --depth 1 "$PUBLIC_REPO" "$work/public" 2>/dev/null
# works for a new, empty repo as well as one that already has a main branch
git -C "$work/public" switch --quiet main 2>/dev/null || git -C "$work/public" switch --quiet --orphan main

echo "Copying the apps..."
# start from an empty tree, so files deleted in the source are deleted in the public repo too
find "$work/public" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
tar -C "$work/source" \
  --exclude=./.git --exclude=./.github --exclude=./.claude --exclude=./tools \
  --exclude=./.gitattributes --exclude=./README.md --exclude=./CLAUDE.md \
  -cf - . | tar -C "$work/public" -xf -
cat > "$work/public/README.md" <<'EOF'
# AstroEngr 445 lesson apps

Interactive lecture apps for AstroEngr 445, served with GitHub Pages from this repo.

This repo is generated: every publish from the course's source repo copies the apps here.
Changes made directly in this repo will be overwritten.
EOF

cd "$work/public"
git add -A
if git diff --cached --quiet; then
  printf '\nThe public site is already up to date with source commit %s.\n' "$sha"
  exit 0
fi
printf '\nChanges to publish:\n'
git diff --cached --stat
if [ "$DRY_RUN" = 1 ]; then
  printf '\nDry run: nothing was pushed.\n'
  exit 0
fi
git commit --quiet -m "Publish $sha from the source repo"
printf '\nPushing to the public repo...\n'
git push --quiet origin main
printf '\nPublished source commit %s. GitHub Pages updates in a minute or two.\n' "$sha"
