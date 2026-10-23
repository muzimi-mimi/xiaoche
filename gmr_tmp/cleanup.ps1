$procs = Get-Process WINWORD -ErrorAction SilentlyContinue
if (-not $procs) { Write-Output "no WINWORD running"; exit }
foreach ($p in $procs) {
    $title = $p.MainWindowTitle
    if ([string]::IsNullOrWhiteSpace($title)) {
        Stop-Process -Id $p.Id -Force
        Write-Output ("killed headless PID " + $p.Id)
    } else {
        Write-Output ("KEPT visible PID " + $p.Id + " title=" + $title)
    }
}
