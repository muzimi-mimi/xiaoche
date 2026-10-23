$ErrorActionPreference = "Stop"
$w = $null; $d = $null
try {
    $path = (Resolve-Path "verify.docx").Path
    $w = New-Object -ComObject Word.Application
    $w.Visible = $false
    $w.DisplayAlerts = 0
    $d = $w.Documents.Open($path, $false, $true)
    $om = $d.OMaths
    Write-Output ("paragraphs={0} tables={1} images={2} pages={3} OMaths={4}" -f `
        $d.Paragraphs.Count, $d.Tables.Count, $d.InlineShapes.Count, $d.ComputeStatistics(2), $om.Count)
    foreach ($idx in @(1, 6, 12, 30, 66, 100, 133)) {
        if ($idx -le $om.Count) {
            $e = $om.Item($idx)
            $t = $e.Range.Text
            if ($t.Length -gt 70) { $t = $t.Substring(0, 70) }
            Write-Output ("  eq{0} type={1} : {2}" -f $idx, $e.Type, ($t -replace "[\r\x07\a]", ""))
        }
    }
} catch {
    Write-Output ("ERR: " + $_.Exception.Message)
} finally {
    if ($d) { $d.Close($false) }
    if ($w) { $w.Quit() }
}
