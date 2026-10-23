$ErrorActionPreference = "Continue"
$pp = $null
$pp = New-Object -ComObject PowerPoint.Application
foreach ($f in $args) {
    if (-not (Test-Path $f)) { continue }
    $p = (Resolve-Path $f).Path
    Write-Output ("=== " + (Split-Path $p -Leaf))
    # 方式1：单参数 Open
    try { $a = $pp.Presentations.Open($p); Write-Output ("  1arg  OK slides=" + $a.Slides.Count); $a.Close() }
    catch { Write-Output ("  1arg  FAIL: " + $_.Exception.Message) }
    # 方式2：只读打开，带窗口
    try { $b = $pp.Presentations.Open($p, $true, $false, $true); Write-Output ("  rw+win OK slides=" + $b.Slides.Count); $b.Close() }
    catch { Write-Output ("  rw+win FAIL: " + $_.Exception.Message) }
}
try { $pp.Quit() } catch { }
