<#
.SYNOPSIS
  Publishes the lecture apps from the private Astro-445 repo to the public astro-445-apps repo.

.DESCRIPTION
  Clones the main branch of the source repo and the public repo into a temporary folder,
  replaces the public repo's files with the apps (everything except the source repo's docs,
  settings and tools), and pushes one commit. Nothing on your computer is changed, and you
  do not need a local copy of either repo. It uses your own GitHub sign-in, so you need write
  access to the public repo. Runs in Windows PowerShell 5.1 and PowerShell 7.

  The same files are excluded as in .github/workflows/publish.yml. Keep the two lists in step.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File publish.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File publish.ps1 -DryRun
  Shows what would change without pushing anything.
#>
param(
  [string]$SourceRepo = 'https://github.com/usafa-dfas/Astro-445.git',
  [string]$PublicRepo = 'https://github.com/usafa-dfas/astro-445-apps.git',
  [switch]$DryRun
)

# top-level names in the source repo that are not part of the site
$Exclude = @('.git', '.github', '.claude', 'tools', '.gitattributes', 'README.md', 'CLAUDE.md')

$PublicReadme = @'
# AstroEngr 445 lesson apps

Interactive lecture apps for AstroEngr 445, served with GitHub Pages from this repo.

This repo is generated: every publish from the course's source repo copies the apps here.
Changes made directly in this repo will be overwritten.
'@

function Fail([string]$msg) {
  Write-Host ''
  Write-Host "Publish failed: $msg" -ForegroundColor Red
  exit 1
}
function Invoke-Git {
  # run git with the given arguments; stop if it fails
  & git @args
  if ($LASTEXITCODE -ne 0) { Fail "git $($args -join ' ') exited with code $LASTEXITCODE." }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail 'git is not installed. Install it from https://git-scm.com/downloads, then run this again.'
}
$name = (& git config --get user.name)
$email = (& git config --get user.email)
if (-not $name -or -not $email) {
  Fail ("git does not know who you are. Run these once, with your own details:`n" +
    "  git config --global user.name ""Your Name""`n" +
    "  git config --global user.email ""you@example.com""")
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ('astro445-publish-' + [System.Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $work | Out-Null
$src = Join-Path $work 'source'
$pub = Join-Path $work 'public'

try {
  Write-Host 'Fetching the source repo (main)...' -ForegroundColor Cyan
  Invoke-Git clone --quiet --depth 1 --branch main $SourceRepo $src
  $sha = (& git -C $src rev-parse --short=7 HEAD)

  Write-Host 'Fetching the public repo...' -ForegroundColor Cyan
  Invoke-Git clone --quiet --depth 1 $PublicRepo $pub
  # works for a new, empty repo as well as one that already has a main branch
  & git -C $pub switch --quiet main 2>$null
  if ($LASTEXITCODE -ne 0) { Invoke-Git -C $pub switch --quiet --orphan main }

  Write-Host 'Copying the apps...' -ForegroundColor Cyan
  # start from an empty tree, so files deleted in the source are deleted in the public repo too
  Get-ChildItem -LiteralPath $pub -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force
  Get-ChildItem -LiteralPath $src -Force | Where-Object { $Exclude -notcontains $_.Name } |
    Copy-Item -Destination $pub -Recurse -Force
  [System.IO.File]::WriteAllText((Join-Path $pub 'README.md'), $PublicReadme.Replace("`r`n", "`n") + "`n")

  Invoke-Git -C $pub add -A
  & git -C $pub diff --cached --quiet
  if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host "The public site is already up to date with source commit $sha." -ForegroundColor Green
    return
  }
  Write-Host ''
  Write-Host 'Changes to publish:'
  & git -C $pub diff --cached --stat
  if ($DryRun) {
    Write-Host ''
    Write-Host 'Dry run: nothing was pushed.' -ForegroundColor Yellow
    return
  }
  Invoke-Git -C $pub commit --quiet -m "Publish $sha from the source repo"
  Write-Host ''
  Write-Host 'Pushing to the public repo...' -ForegroundColor Cyan
  Invoke-Git -C $pub push --quiet origin main
  Write-Host ''
  Write-Host "Published source commit $sha. GitHub Pages updates in a minute or two." -ForegroundColor Green
}
finally {
  Set-Location ([System.IO.Path]::GetTempPath())
  Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
