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

`scripts/auto-commit.ps1` appends an entry to `data/log.js`, commits it and
pushes to GitHub.

Run it every morning from this folder and leave the window open:

```powershell
.\scripts\auto-commit.ps1
```

It picks a target of 10-20 commits for the day and waits a random 15-50
minutes between commits. If you close the window early, run it again and it
carries on (commits already made today count toward the target). It stops
before midnight.

Make one commit right now instead:

```powershell
.\scripts\auto-commit.ps1 -Once
```

Each run is recorded in `auto-commit.log` (ignored by git).
