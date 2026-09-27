# Removes the scheduled task created by install-schedule.ps1.

Unregister-ScheduledTask -TaskName "commiting-auto" -Confirm:$false
Write-Host "Scheduled task 'commiting-auto' removed."
