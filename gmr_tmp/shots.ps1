$ErrorActionPreference = "Stop"
$pp = $null; $pres = $null
try {
    $p = (Resolve-Path "check.pptx").Path
    $dir = Join-Path (Get-Location).Path "shots"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($p, -1, 0, 0)
    foreach ($sl in $pres.Slides) {
        $f = Join-Path $dir ("slide{0}.png" -f $sl.SlideIndex)
        $sl.Export($f, "PNG", 1280, 720)
        Write-Output ("exported " + $f)
    }
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
finally { if ($pres) { $pres.Close() }; if ($pp) { $pp.Quit() } }
