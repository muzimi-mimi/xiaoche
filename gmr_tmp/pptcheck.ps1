$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$p = (Resolve-Path "check.pptx").Path

# --- 1) 所有 XML 部件必须良构 ---
$z = [System.IO.Compression.ZipFile]::OpenRead($p)
$bad = 0
foreach ($e in $z.Entries) {
    if ($e.FullName -like "*.xml" -or $e.FullName -like "*.rels") {
        $sr = New-Object System.IO.StreamReader($e.Open(), [System.Text.Encoding]::UTF8)
        $txt = $sr.ReadToEnd(); $sr.Close()
        try { [xml]$d = $txt } catch { $bad++; Write-Output ("XMLFAIL {0} :: {1}" -f $e.FullName, $_.Exception.Message) }
    }
}
$z.Dispose()
Write-Output ("xml parts bad=" + $bad)

# --- 2) PowerPoint 真机打开 ---
$pp = $null; $pres = $null
try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($p, -1, 0, 0)
    Write-Output ("OPENED slides=" + $pres.Slides.Count + " size=" + $pres.PageSetup.SlideWidth + "x" + $pres.PageSetup.SlideHeight)
    foreach ($sl in $pres.Slides) {
        $n = $sl.Shapes.Count
        $pics = 0; $txt = ""
        foreach ($sh in $sl.Shapes) {
            if ($sh.Type -eq 13) { $pics++ }
            if ($sh.HasTextFrame -and $sh.TextFrame.HasText) { $txt += $sh.TextFrame.TextRange.Text + " | " }
        }
        if ($txt.Length -gt 120) { $txt = $txt.Substring(0, 120) }
        Write-Output ("  slide{0}: shapes={1} pics={2}  {3}" -f $sl.SlideIndex, $n, $pics, $txt)
    }
} catch {
    Write-Output ("PPERR: " + $_.Exception.Message)
} finally {
    if ($pres) { $pres.Close() }
    if ($pp) { $pp.Quit() }
}
