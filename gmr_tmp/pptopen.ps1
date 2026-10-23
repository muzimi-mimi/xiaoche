$ErrorActionPreference = "Continue"
$pp = $null
try { $pp = New-Object -ComObject PowerPoint.Application } catch { Write-Output ("NO_PP: " + $_.Exception.Message); exit }
Write-Output ("PP version " + $pp.Version)
$targets = @()
foreach ($f in $args) { if (Test-Path $f) { $targets += (Resolve-Path $f).Path } }
foreach ($t in $targets) {
    $pres = $null
    Write-Output ("--- trying: " + (Split-Path $t -Leaf))
    try {
        $pres = $pp.Presentations.Open($t, -1, 0, 0)     # ReadOnly=true, Untitled=false, WithWindow=false
        Write-Output ("    OK slides=" + $pres.Slides.Count)
        $pres.Close()
    } catch {
        Write-Output ("    FAIL(withwindow=0): " + $_.Exception.Message)
        try {
            $pp.Visible = -1
            $pres = $pp.Presentations.Open($t, -1, 0, -1)
            Write-Output ("    OK(visible-mode) slides=" + $pres.Slides.Count)
            $pres.Close()
        } catch {
            Write-Output ("    FAIL(visible-mode): " + $_.Exception.Message)
        }
    }
}
try { $pp.Quit() } catch { }
