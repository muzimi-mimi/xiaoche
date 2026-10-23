$ErrorActionPreference = "Continue"
$src = (Resolve-Path "base.pptx").Path
$pp = $null; $pres = $null
try {
    $pp = New-Object -ComObject PowerPoint.Application
    $pres = $pp.Presentations.Open($src, $false, $false, $false)
    $sl = $pres.Slides.Item(1)
    $np = $sl.NotesPage
    Write-Output ("NotesPage shapes = " + $np.Shapes.Count)
    $k = 0
    foreach ($sh in $np.Shapes) {
        $k++
        $pht = "?"
        try { $pht = $sh.PlaceholderFormat.Type } catch { $pht = "not-a-ph" }
        Write-Output ("  item{0}: name='{1}' type={2} phType={3} hasTextFrame={4} isPlaceholder={5}" -f `
            $k, $sh.Name, $sh.Type, $pht, $sh.HasTextFrame, $sh.PlaceholderFormat)
    }
    Write-Output ("Placeholders.Count = " + $np.Placeholders.Count)
    $m = 0
    foreach ($ph in $np.Placeholders) {
        $m++
        Write-Output ("  ph{0}: name='{1}' phType={2}" -f $m, $ph.Name, $ph.PlaceholderFormat.Type)
    }
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
finally { if ($pres) { $pres.Close() }; if ($pp) { $pp.Quit() } }
