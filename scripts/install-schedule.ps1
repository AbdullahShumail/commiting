# Registers a Windows scheduled task that runs auto-commit.ps1 every 45 minutes
# from 08:30 until midnight. With the random gaps in auto-commit.ps1 that works
# out to roughly 10-20 commits a day while this PC is on.
#
# Remove it again with:  .\scripts\uninstall-schedule.ps1

$TaskName = "commiting-auto"
$script = Join-Path $PSScriptRoot "auto-commit.ps1"

# conhost --headless keeps a console window from flashing up on every run.
$action = New-ScheduledTaskAction -Execute "conhost.exe" `
  -Argument "--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$script`""

$trigger = New-ScheduledTaskTrigger -Daily -At "08:30"
$trigger.Repetition = (New-ScheduledTaskTrigger -Once -At "08:30" `
  -RepetitionInterval (New-TimeSpan -Minutes 45) `
  -RepetitionDuration (New-TimeSpan -Hours 15 -Minutes 29)).Repetition

$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
  -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Minutes 30) -MultipleInstances IgnoreNew

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
  -Settings $settings -Principal $principal -Force | Out-Null

Write-Host "Scheduled task '$TaskName' installed."
