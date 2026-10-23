$ErrorActionPreference = "Stop"
$w = $null; $d = $null
try {
    $path = (Resolve-Path "verify.docx").Path
    $w = New-Object -ComObject Word.Application
    $w.Visible = $false
    $w.DisplayAlerts = 0
    $d = $w.Documents.Open($path, $false, $true)
    $tw = $d.PageSetup.TextWidth
    Write-Output ("TextWidth(twips)=" + $tw)
    $i = 0
    foreach ($t in $d.Tables) {
        $i++
        $cols = $t.Columns.Count
        $rows = $t.Rows.Count
        $wid = $t.Width
        $flag = if ($wid -gt $tw + 20) { "  <== OVERFLOW" } else { "" }
        Write-Output ("table{0}: cols={1} rows={2} width={3}{4}" -f $i, $cols, $rows, [math]::Round($wid, 0), $flag)
    }
    $r = $d.Range(0, [Math]::Min(700, $d.Content.End - 1))
    Write-Output "----HEAD----"
    Write-Output ($r.Text -replace "[\r\x07]", " ")
    $tailStart = [Math]::Max(0, $d.Content.End - 500)
    Write-Output "----TAIL----"
    Write-Output ($d.Range($tailStart, $d.Content.End - 1).Text -replace "[\r\x07]", " ")
    Write-Output ("images=" + $d.InlineShapes.Count + " pages=" + $d.ComputeStatistics(2))
} catch {
    Write-Output ("ERR: " + $_.Exception.Message)
} finally {
    if ($d) { $d.Close($false) }
    if ($w) { $w.Quit() }
}
