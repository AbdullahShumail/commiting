# Adds entries to data/log.js, commits them, and pushes to GitHub.
#
#   .\scripts\auto-commit.ps1         run for the day: 10-20 commits with random
#                                     gaps between them. Keep the window open.
#   .\scripts\auto-commit.ps1 -Once   make a single commit right now

param([switch]$Once)

$ErrorActionPreference = "Stop"
$MinPerDay = 10
$MaxPerDay = 20
$MinGap = 15      # minutes between commits
$MaxGap = 50
$StopAt = "23:45" # never let a commit slip into tomorrow

$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$logFile = Join-Path $repo "auto-commit.log"

function Write-Log($msg) {
  $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
  Write-Host $line
  Add-Content -Path $logFile -Value $line
}

function Get-TodayCount {
  $email = git config user.email
  $today = Get-Date -Format "yyyy-MM-dd"
  @(git log --since="$today 00:00" --author="$email" --format="%h").Count
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

function New-Commit {
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
    Write-Log "committed, push failed (goes out with the next push): $text"
  } else {
    Write-Log "committed and pushed: $text"
  }
}

try {
  if ($Once) {
    New-Commit
    exit 0
  }

  $target = Get-Random -Minimum $MinPerDay -Maximum ($MaxPerDay + 1)
  $done = Get-TodayCount
  $startDay = (Get-Date).Date
  $deadline = [datetime]::ParseExact($StopAt, "HH:mm", $null)
  Write-Log "day run started: target $target commits, $done already today"

  while ($done -lt $target) {
    New-Commit
    $done++
    Write-Log "progress: $done / $target"
    if ($done -ge $target) { break }

    # Shrink the gaps if the remaining commits wouldn't fit before the deadline.
    $minutesLeft = ($deadline - (Get-Date)).TotalMinutes
    $maxGap = [Math]::Min($MaxGap, $minutesLeft / ($target - $done))
    if ($maxGap -lt 1) { $maxGap = 1 }
    $minGap = [Math]::Min($MinGap, $maxGap / 2)
    $gap = Get-Random -Minimum $minGap -Maximum $maxGap
    $next = (Get-Date).AddMinutes($gap)
    Write-Log ("next commit at {0:HH:mm}" -f $next)
    Start-Sleep -Seconds ([int]($gap * 60))

    if ((Get-Date).Date -ne $startDay) {
      Write-Log "past midnight, stopping"
      break
    }
  }
  Write-Log "day run finished: $done commits today"
} catch {
  Write-Log "error: $_"
  exit 1
}
