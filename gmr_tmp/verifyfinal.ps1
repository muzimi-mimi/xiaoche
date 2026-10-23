$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$src = (Resolve-Path "final.pptx").Path
$pp = $null; $pres = $null
try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($src, -1, 0, 0)
    Write-Output ("OPENED slides=" + $pres.Slides.Count)
    foreach ($sl in $pres.Slides) {
        $body = $null
        foreach ($sh in $sl.NotesPage.Shapes) {
            try { if ($sh.PlaceholderFormat.Type -eq 2) { $body = $sh; break } } catch { }
        }
        $t = ""
        if ($body) { $t = $body.TextFrame.TextRange.Text }
        $t = $t -replace [string][char]13, " / "
        $head = if ($t.Length -gt 78) { $t.Substring(0, 78) } else { $t }
        Write-Output ("  slide{0} notesChars={1}  {2}" -f $sl.SlideIndex, $t.Length, $head)
    }
    $dir = Join-Path (Get-Location).Path "shots"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    foreach ($sl in $pres.Slides) { $sl.Export((Join-Path $dir ("slide{0}.png" -f $sl.SlideIndex)), "PNG", 1280, 720) }
    Write-Output "SHOTS_OK"
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
finally { if ($pres) { $pres.Close() }; if ($pp) { $pp.Quit() } }
