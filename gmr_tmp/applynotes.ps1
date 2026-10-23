$ErrorActionPreference = "Stop"
$src = (Resolve-Path "base.pptx").Path
$json = Get-Content -Raw -Encoding UTF8 "notes.json" | ConvertFrom-Json
$pp = $null; $pres = $null
try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($src, $false, $false, $false)
    $i = 0
    foreach ($sl in $pres.Slides) {
        if ($i -ge $json.Count) { break }
        $body = $null
        foreach ($sh in $sl.NotesPage.Shapes) {
            try { if ($sh.PlaceholderFormat.Type -eq 2) { $body = $sh; break } } catch { }
        }
        if ($body -eq $null) { Write-Output ("MISSING_BODY slide" + $sl.SlideIndex); $i++; continue }
        # PowerPoint 段落分隔用 Chr(13)
        $t = ($json[$i] -replace "`r`n", "`n") -replace "`n", [string][char]13
        $body.TextFrame.TextRange.Text = $t
        $body.TextFrame.TextRange.Font.Size = 11
        Write-Output ("OK slide{0} chars={1}" -f $sl.SlideIndex, $json[$i].Length)
        $i++
    }
    $out = Join-Path (Get-Location).Path "final.pptx"
    if (Test-Path $out) { Remove-Item $out -Force }
    $pres.SaveCopyAs($out, 24)
    Write-Output ("SAVED slides=" + $pres.Slides.Count)
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
finally { if ($pres) { $pres.Close() }; if ($pp) { $pp.Quit() } }
