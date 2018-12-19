$date = [System.Convert]::ToDateTime((Get-Process w3wp | % { $_.StartTime }))
$uptime = (Get-Date) - $date
Write-Host $uptime