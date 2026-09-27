# commiting

A small personal website, built and updated a little bit every day.

Open `index.html` in a browser to view it.

## Structure

```
index.html          the page
css/style.css       styles (dark by default, light theme toggle)
js/main.js          renders the daily log, footer year, theme toggle
data/log.js         daily log entries (appended automatically)
favicon.svg         contribution-graph style icon
scripts/            automation for the daily log
```

## Daily log automation

`scripts/auto-commit.ps1` appends one entry to `data/log.js`, commits it and
pushes to GitHub. It randomly skips some runs so commits land at uneven gaps,
caps itself at 20 commits a day, and never skips late in the day if there are
fewer than 10.

Install the scheduled task (runs every 45 minutes, 08:30 until midnight):

```powershell
.\scripts\install-schedule.ps1
```

Remove it:

```powershell
.\scripts\uninstall-schedule.ps1
```

Run it once by hand, with no random skip or delay:

```powershell
.\scripts\auto-commit.ps1 -Force
```

Each run is recorded in `auto-commit.log` (ignored by git).
