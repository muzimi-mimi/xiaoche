$ErrorActionPreference = "Stop"
$pp = $null; $pres = $null
try {
    $p = (Resolve-Path "check.pptx").Path
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($p, -1, 0, 0)
    Write-Output ("OPENED slides=" + $pres.Slides.Count)
    foreach ($sl in $pres.Slides) {
        $hasNotes = $false; $nt = ""
        try {
            $ns = $sl.NotesPage
            $hasNotes = $true
            foreach ($sh in $ns.Shapes) {
                if ($sh.HasTextFrame -and $sh.TextFrame.HasText) { $nt += $sh.TextFrame.TextRange.Text }
            }
        } catch { $hasNotes = $false }
        $len = $nt.Length
        $head = ""
        if ($len -gt 0) { $head = $nt.Substring(0, [Math]::Min(60, $len)) }
        Write-Output ("  slide{0}: notes={1} chars={2}  {3}" -f $sl.SlideIndex, $hasNotes, $len, ($head -replace "\r", " / "))
    }
    $dir = Join-Path (Get-Location).Path "shots"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    foreach ($sl in $pres.Slides) { $sl.Export((Join-Path $dir ("slide{0}.png" -f $sl.SlideIndex)), "PNG", 1280, 720) }
    Write-Output "shots exported"
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
finally { if ($pres) { $pres.Close() }; if ($pp) { $pp.Quit() } }
