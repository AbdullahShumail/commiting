# Adds one entry to data/log.js, commits it, and pushes to GitHub.
# Run by the "commiting-auto" scheduled task (see install-schedule.ps1).
#
#   -Force   skip the random skip/delay and the daily cap (for manual runs)

param([switch]$Force)

$ErrorActionPreference = "Stop"
$MaxPerDay = 20
$MinPerDay = 10
$SkipChance = 20   # percent

$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$logFile = Join-Path $repo "auto-commit.log"

function Write-Log($msg) {
  $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
  Add-Content -Path $logFile -Value $line
}

try {
  $email = (git config user.email)
  $today = Get-Date -Format "yyyy-MM-dd"
  $doneToday = @(git log --since="$today 00:00" --author="$email" --format="%h").Count

  if (-not $Force) {
    if ($doneToday -ge $MaxPerDay) {
      Write-Log "skip: already $doneToday commits today"
      exit 0
    }
    # Late in the day and still under the minimum: never skip.
    $behind = ((Get-Date).Hour -ge 21) -and ($doneToday -lt $MinPerDay)
    if (-not $behind -and (Get-Random -Maximum 100) -lt $SkipChance) {
      Write-Log "skip: random gap"
      exit 0
    }
    # Spread commit times out a bit so they don't land on the same minute.
    Start-Sleep -Seconds (Get-Random -Minimum 0 -Maximum 600)
  }

  $verbs = @(
    "Practiced", "Read about", "Reviewed", "Took notes on", "Experimented with",
    "Revisited", "Worked through an exercise on", "Watched a short talk on",
    "Wrote a small example of", "Refreshed my memory on"
  )
  $topics = @(
    "CSS grid", "flexbox alignment", "CSS custom properties", "media queries",
    "semantic HTML", "accessibility and ARIA labels", "keyboard navigation",
    "JavaScript closures", "array methods", "the event loop", "promises",
    "async/await", "fetch and JSON", "DOM events", "event delegation",
    "localStorage", "ES modules", "destructuring", "template literals",
    "regular expressions", "git rebase", "git branching", "writing good commit messages",
    "merge conflicts", "GitHub Pages", "responsive images", "web performance",
    "lazy loading", "CSS animations", "transitions and easing", "color contrast",
    "typography scales", "SVG basics", "form validation", "HTTP status codes",
    "REST APIs", "debugging in DevTools", "Big-O notation", "recursion",
    "sorting algorithms", "binary search", "hash maps", "linked lists",
    "stacks and queues", "clean code habits", "naming things", "unit testing"
  )
  $text = "{0} {1}." -f (Get-Random -InputObject $verbs), (Get-Random -InputObject $topics)
  $time = Get-Date -Format "yyyy-MM-dd HH:mm"

  $entry = 'LOG.push({ time: "' + $time + '", text: "' + $text + '" });' + "`n"
  [System.IO.File]::AppendAllText((Join-Path $repo "data\log.js"), $entry)

  # Commit only the log file, so any other work in progress is left alone.
  git add data/log.js
  git commit -q -m "Log: $text" -- data/log.js
  if ($LASTEXITCODE -ne 0) { throw "git commit failed" }

  git pull -q --rebase --autostash origin main
  if ($LASTEXITCODE -ne 0) { git rebase --abort }
  git push -q origin main
  if ($LASTEXITCODE -ne 0) {
    Write-Log "committed but push failed (will go out with the next push): $text"
  } else {
    Write-Log "committed and pushed ($($doneToday + 1) today): $text"
  }
} catch {
  Write-Log "error: $_"
  exit 1
}
