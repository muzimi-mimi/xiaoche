$ErrorActionPreference = 'Stop'
$path = 'D:\Users\huang\Desktop\keil\PID\Core\Src\main.c'
$gbk  = [System.Text.Encoding]::GetEncoding(936)
$lat  = [System.Text.Encoding]::GetEncoding(28591)
$nl   = "`r`n"
$t4   = ("`t" * 4)
$t5   = ("`t" * 5)

$bak = Join-Path $env:TEMP 'main.c.bak_before_speed'
[System.IO.File]::WriteAllBytes($bak, [System.IO.File]::ReadAllBytes($path))
"backup -> $bak"

$bytes = [System.IO.File]::ReadAllBytes($path)
$s = $lat.GetString($bytes)
$fail = @()

function Chk([string]$name, [string]$hay, [string]$needle, [int]$want) {
    $c = 0; $i = 0
    while (($i = $hay.IndexOf($needle, $i, [System.StringComparison]::Ordinal)) -ge 0) { $c++; $i += $needle.Length }
    if ($c -ne $want) { return "$name : found $c, expected $want" }
    return $null
}

# ---------------- 1. 新增 TRACK_SPEED 常量 ----------------
$blk1 = @(
'#define TRACK_SPEED    0.08f    /* 循迹前进速度：输出轴 转/秒，直接写进 SpeedPID.Target',
'                                 * ★ 必须给：joystick 分支只在 !TrackMode 时才写 SpeedPID.Target，',
'                                 *   循迹模式下没人给速度 -> Target 恒 0 -> AnglePID.Target 恒 0',
'                                 *   -> 车只剩差速、原地打转，不前进。',
'                                 * 0.08 是"尽可能慢"的下限，不是随手挑的数：',
'                                 *   44线编码器 x 30减速比，50ms 采样 -> 1 计数 = 0.0152 转/秒；',
'                                 *   AveSpeed 取两轮平均 -> 量化台阶 0.0076 转/秒。',
'                                 *   0.08 时每 50ms 只有 5.3 个计数(量化 9.4%)，再低就数不清了。',
'                                 * 起步靠积分：ErrorInt 每拍涨 Ki*v，约 2.3 秒才攒到 1 度倾角，',
'                                 *   所以从静止到走起来有约 2 秒的"酝酿"，不是故障。',
'                                 * 车速换算(轮径 65mm -> 周长 204mm)：0.08 x 204 = 16 mm/s。',
'                                 * 想调：0.06 更慢(4.0 计数/50ms，起步约 3.3 秒)；一顿一顿就加到 0.10 */'
) -join $nl
$blk1 = $lat.GetString($gbk.GetBytes($blk1))

$pat1 = [regex]'(?m)^#define TRACK_LOST_MAX[^\r\n]*'
$m1 = $pat1.Match($s)
if (-not $m1.Success) { $fail += 'patch1: TRACK_LOST_MAX anchor not found' }
else {
    $at = $m1.Index + $m1.Length
    $s = $s.Substring(0, $at) + $nl + $blk1 + $s.Substring($at)
}

# ---------------- 2. 50ms 速度环里给前进速度 ----------------
$anchor2 = $lat.GetString($gbk.GetBytes('/*速度环PID计算*/'))
$e = Chk 'patch2' $s $anchor2 1
if ($e) { $fail += $e } else {
    $blk2 = @(
    '/* ---------- 循迹前进速度；丢线超时归零 -> 原地直立 ----------',
    ($t4 + ' * 摇杆分支不再负责循迹时的前进速度(见 joystick 里的 !TrackMode 判断)，这里必须给。'),
    ($t4 + ' * 否则 SpeedPID.Target 恒 0：速度环把车速稳到 0，AnglePID.Target 跟着变 0，'),
    ($t4 + ' * 车只剩 DifPWM 差速 -> 原地打转、不前进。'),
    ($t4 + ' * 丢线超过 TRACK_LOST_MAX(25 帧 x 40ms = 1s)：这里与 CCD 块里的 TurnPID.Target'),
    ($t4 + ' * 同时归零 -> 车停住并原地直立，不再盲走冲出赛道。 */'),
    ($t4 + 'if (TrackMode)'),
    ($t5 + 'SpeedPID.Target = (TrackLostCnt >= TRACK_LOST_MAX) ? 0.0f : TRACK_SPEED;'),
    '',
    ($t4 + '/*速度环PID计算*/')
    ) -join $nl
    $blk2 = $lat.GetString($gbk.GetBytes($blk2))
    $s = $s.Replace($anchor2, $blk2)
}

# ---------------- 3. joystick 前进速度加 !TrackMode 保护 ----------------
$o3 = 'SpeedPID.Target = LV / 50.0;'
$n3 = 'if (!TrackMode) SpeedPID.Target = LV / 50.0;   /* 循迹时前进速度由 TRACK_SPEED 在 50ms 层给 */'
$n3 = $lat.GetString($gbk.GetBytes($n3))
$e = Chk 'patch3' $s $o3 1
if ($e) { $fail += $e } else { $s = $s.Replace($o3, $n3) }

# ---------------- 4. 丢线注释改成"原地直立" ----------------
$o4 = $lat.GetString($gbk.GetBytes('/* 丢线太久：放弃转向，只求直行 */'))
$n4 = $lat.GetString($gbk.GetBytes('/* 丢线太久：转向归零；前进速度在 50ms 层同时归零 -> 原地直立 */'))
$e = Chk 'patch4' $s $o4 1
if ($e) { $fail += $e } else { $s = $s.Replace($o4, $n4) }

# ---------------- 5. 块注释同步 ----------------
$o5 = $lat.GetString($gbk.GetBytes('(改成直行)，避免在长直道尽头或大弯处突然打死。'))
$n5 = $lat.GetString($gbk.GetBytes('；同时 50ms 层把前进速度也归零 -> 原地直立，不再盲走。'))
$e = Chk 'patch5' $s $o5 1
if ($e) { $fail += $e } else { $s = $s.Replace($o5, $n5) }

# ---------------- 写回 ----------------
$out = $lat.GetBytes($s)
[System.IO.File]::WriteAllBytes($path, $out)
"orig bytes = $($bytes.Length)  new bytes = $($out.Length)  delta = $($out.Length - $bytes.Length)"

if ($fail.Count -gt 0) {
    "FAILED:"
    $fail | ForEach-Object { "  $_" }
    "!! file was written anyway - restore from $bak if needed"
    exit 1
}
"all 5 patches applied"

$vtext = $gbk.GetString([System.IO.File]::ReadAllBytes($path))
$vlines = $vtext -split "`r`n"
"----- verified regions -----"
for ($i = 0; $i -lt $vlines.Count; $i++) {
    if ($vlines[$i] -match 'TRACK_SPEED|if \(TrackMode\)|if \(!TrackMode\) SpeedPID|原地直立|/\\*速度环PID计算') {
        "{0,4}: {1}" -f ($i + 1), $vlines[$i]
    }
}
$bad = ([regex]::Matches($vtext, '\?{2,}')).Count
"question-mark runs (??...) = $bad   (must be 0)"
