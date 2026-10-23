$ErrorActionPreference = "Stop"
$w = $null; $d = $null
try {
    $path = (Resolve-Path "verify.docx").Path
    $w = New-Object -ComObject Word.Application
    $w.Visible = $false
    $w.DisplayAlerts = 0
    $d = $w.Documents.Open($path, $false, $true)
    $info = "paragraphs={0} tables={1} inlineShapes={2} pages={3} words={4}" -f `
        $d.Paragraphs.Count, $d.Tables.Count, $d.InlineShapes.Count, `
        $d.ComputeStatistics(2), $d.ComputeStatistics(0)
    Write-Output ("OPENED " + $info)
    $pdf = Join-Path (Get-Location).Path "preview.pdf"
    $d.ExportAsFixedFormat($pdf, 17)
    Write-Output "PDF_OK"
} catch {
    Write-Output ("ERR: " + $_.Exception.Message)
} finally {
    if ($d) { $d.Close($false) }
    if ($w) { $w.Quit() }
}
