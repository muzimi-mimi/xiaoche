<#
=============================================================================
 校园网门户自动登录脚本  (Dr.COM / 哆点 认证门户)
 目标门户 : http://10.0.1.5/   (桂林电子科技大学)
 门户类型 : Dr.COM ePortal, page_name = youxianbendi_17

 【工作方式】开机后按下面顺序尝试，哪一种成功就停：
   1) 查在线状态 /drcom/chkstatus —— 已在线就直接收工（最快）
   2) 快速试探：GET /drcom/login  —— 有些时候门户直接放行，不用开浏览器
   3) 主力方案：用 Edge 的 DevTools 协议打开门户页，像人一样
      填账号、填密码、点“中国移动”、点登录 —— 与手动登录完全等价，最可靠

 登录接口 : GET http://10.0.1.5/drcom/login
 状态接口 : GET http://10.0.1.5/drcom/chkstatus
 运营商   : 通过“账号后缀”选择（enable_r3=0，中国移动 => @cmcc）
=============================================================================
 自定义说明：只需要改下面【配置区】的几行即可，其余不用动。
=============================================================================
#>
[CmdletBinding()]
param(
    # 即使检测到已在线，也强制执行一次登录
    [switch]$Force,
    # 不打开/不启动浏览器（只用接口方式）
    [switch]$NoBrowser,
    # 只检测状态、不执行登录（用于排查）
    [switch]$StatusOnly,
    # 只注销当前认证，不登录（用于自测"离线后能否自动登回"）
    [switch]$Logout,
    # 跳过 HTTP 快速试探，直接走浏览器自动化
    [switch]$NoHttp,
    # 只测浏览器自动化通道（会打开一个浏览器窗口，不提交登录）
    [switch]$TestBrowser
)

$ErrorActionPreference = 'Continue'

# ============================== 配置区 ==============================
$PortalHost   = '10.0.1.5'                # 门户地址
$PortalUrl    = 'http://10.0.1.5/'        # 要打开的浏览器网址
$Account      = '2500220712'              # 账号（不带后缀）
$Password     = '12345678Hua.'            # 密码
$Carrier      = '中国移动'                 # 通道：校园网 / 中国移动 / 中国联通 / 中国电信
# 账号是否拼运营商后缀（中国移动 => @cmcc）：
#   'none'   = 只用纯账号 2500220712，不拼后缀
#   'portal' = 交给门户自己的逻辑拼（门户会拼成 2500220712@cmcc）
#   'auto'   = 先试 'none'，这一轮没登上，下一轮自动换 'portal' 再试（推荐）
$SuffixMode   = 'auto'
$MaxTry       = 12                        # 最多尝试轮数（开机时网络可能没就绪）
$RetryDelay   = 10                        # 每轮失败后等待秒数
$OpenBrowser  = $true                     # 完成后是否打开/保留浏览器
$CdpPort      = 19222                     # 浏览器自动化用的调试端口（一般不用改）
# ====================================================================

# 通道 -> 账号后缀 映射（来自门户下发的 carrier 配置）
$CarrierMap = @{
    '校园网'   = ''
    '中国移动' = '@cmcc'
    '中国联通' = '@unicom'
    '中国电信' = '@telecom'
}

$ScriptDir  = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$LogFile    = Join-Path $ScriptDir 'AutoLogin.log'
$ProfileDir = Join-Path $env:LOCALAPPDATA 'PortalAutoLogin\edge-profile'

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Write-Host $line
    try {
        if (Test-Path $LogFile) {
            if ((Get-Item $LogFile).Length -gt 512KB) { Remove-Item $LogFile -Force -ErrorAction SilentlyContinue }
        }
        Add-Content -Path $LogFile -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch { }
}

# ---------------------------- HTTP 基础 ----------------------------
function Invoke-PortalGet {
    param([string]$Url, [int]$TimeoutSec = 8)
    $req = $null
    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.Method           = 'GET'
        $req.Timeout          = $TimeoutSec * 1000
        $req.ReadWriteTimeout = $TimeoutSec * 1000
        $req.UserAgent        = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36'
        $req.Referer          = "http://$PortalHost/"
        $req.KeepAlive        = $false
        $req.Proxy            = $null          # 绕过系统代理
        $resp   = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream(), [System.Text.Encoding]::UTF8)
        $text   = $reader.ReadToEnd()
        $reader.Close(); $resp.Close()
        return $text
    } catch {
        try {
            $resp = $_.Exception.Response
            if ($resp) {
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream(), [System.Text.Encoding]::UTF8)
                $text = $reader.ReadToEnd(); $reader.Close()
                if ($text) { return $text }
            }
        } catch { }
        try { if ($req) { $req.Abort() } } catch { }
        return $null
    }
}

function Test-PortalReachable {
    $client = $null
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($PortalHost, 80, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne(2000)) { return $false }
        $client.EndConnect($iar)
        return $true
    } catch { return $false }
    finally { try { if ($client) { $client.Close() } } catch { } }
}

function Get-LocalIPv4 {
    try {
        $udp = New-Object System.Net.Sockets.UdpClient
        $udp.Connect($PortalHost, 80)
        $ip = $udp.Client.LocalEndPoint.Address.ToString()
        $udp.Close()
        if ($ip -and $ip -notmatch '^(127\.|0\.0\.0\.0$|169\.254\.)') { return $ip }
    } catch { }
    return ''
}

function Get-LocalIPv6List {
    $out = @()
    $ok = { $_.IPAddress -notmatch '^(fe80|::1|fd[0-9a-f]{2}|fc[0-9a-f]{2}|2001:0:)' -and $_.AddressState -eq 'Preferred' }
    try {
        $v4  = Get-LocalIPv4
        $idx = $null
        if ($v4) {
            $idx = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                   Where-Object { $_.IPAddress -eq $v4 } | Select-Object -First 1 -ExpandProperty InterfaceIndex
        }
        $all = Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object $ok
        if ($idx) {
            $onIf = @($all | Where-Object { $_.InterfaceIndex -eq $idx })
            if ($onIf.Count -gt 0) {
                $out += @($onIf | Where-Object { $_.SuffixOrigin -ne 'Random' } | Select-Object -ExpandProperty IPAddress)
                $out += @($onIf | Select-Object -ExpandProperty IPAddress)
            }
        }
        $out += @($all | Select-Object -ExpandProperty IPAddress)
    } catch { }
    return @($out | Select-Object -Unique)
}

# 预热：先像浏览器一样打开一次门户页（让 AC 登记本机）
function Invoke-PortalPrime {
    $t = Invoke-PortalGet "http://$PortalHost/" 10
    if ($t -and $t -match 'Dr\.COMWebLoginID_(\d+)') { return $matches[1] }
    return ''
}

function Get-PortalStatus {
    $text = Invoke-PortalGet "http://$PortalHost/drcom/chkstatus?callback=cb" 8
    $r = @{ Online = $null; Uid = ''; Raw = $text }
    if (-not $text) { return $r }
    if ($text -match '"result"\s*:\s*(\d+)') { $r.Online = ([int]$matches[1] -eq 1) }
    if ($text -match '"uid"\s*:\s*"([^"]*)"') { $r.Uid = $matches[1] }
    return $r
}

function Get-PortalMd5Flag {
    $text = Invoke-PortalGet "http://${PortalHost}:801/eportal/portal/page/loadConfig?program_index=2" 6
    if (-not $text) { return 0 }
    if ($text -match '"en_md5"\s*:\s*"?(\d)"?') { return [int]$matches[1] }
    return 0
}

# ---------------------- 方式 A：HTTP 直接登录 ----------------------
# -User 是最终要提交的账号原文（是否带 @cmcc 由调用方决定）
function Invoke-PortalLogin {
    param([string]$User, [bool]$UseMd5, [string]$Ip6 = '')

    $ip   = Get-LocalIPv4
    $user = $User
    $pass = $Password
    $r2   = ''

    if ($UseMd5) {
        $md5  = [System.Security.Cryptography.MD5]::Create()
        $hash = $md5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes('1' + $Password + '12345678'))
        $hex  = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
        $pass = $hex + '12345678' + '1'
        $r2   = '1'
    }

    $query = @(
        'callback=cb',
        'DDDDD=' + [uri]::EscapeDataString($user),
        'upass=' + [uri]::EscapeDataString($pass),
        '0MKKey=123456',
        'R1=0',
        'R2=' + $r2,
        'R3=0',
        'R6=0',
        'para=00',
        'v4ip=' + $ip,
        'v6ip=' + [uri]::EscapeDataString($ip6),
        'terminal_type=1',
        'lang=zh-cn'
    ) -join '&'

    # 不要附加 jsVersion 参数，否则内核会走另一条分支返回 203
    $text = Invoke-PortalGet "http://$PortalHost/drcom/login?$query" 20

    $res = @{ Ok = $false; Result = $null; Message = ''; Raw = $text }
    if (-not $text) { $res.Message = '登录接口无响应'; return $res }
    if ($text -match '"result"\s*:\s*("?[^",}]*"?)') { $res.Result = $matches[1].Trim('"') }
    if ($text -match '"msga"\s*:\s*"([^"]*)"')     { $res.Message = $matches[1] }
    elseif ($text -match '"msg"\s*:\s*"([^"]*)"')  { $res.Message = $matches[1] }
    elseif ($text -match '<body>\s*([^<]*)')       { $res.Message = $matches[1].Trim() }
    else { $res.Message = $text.Trim() }

    if ($res.Result -eq '1' -or $res.Result -eq 'ok') { $res.Ok = $true }
    elseif ($res.Message -match '(?i)clientip\s+online') { $res.Ok = $true; $res.Message = 'clientip online（本机已在线）' }
    return $res
}

# ==================== 方式 B：驱动浏览器（主力方案） ====================

function Get-EdgePath {
    foreach ($p in @(
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    )) { if ($p -and (Test-Path $p)) { return $p } }
    return ''
}

function Get-CdpJson {
    param([int]$Port, [int]$TimeoutSec = 4)
    try { return (Invoke-WebRequest "http://127.0.0.1:$Port/json/list" -UseBasicParsing -TimeoutSec $TimeoutSec).Content }
    catch { return $null }
}

# 启动（或复用）带调试端口的浏览器，返回页面目标的 WebSocket 地址
function Start-AutomationBrowser {
    param([int]$Port, [string]$Prof, [string]$Url)
    $json = Get-CdpJson $Port
    if (-not $json) {
        $edge = Get-EdgePath
        if (-not $edge) { Write-Log '找不到 Edge/Chrome 可执行文件' 'ERROR'; return $null }
        New-Item -ItemType Directory -Force -Path $Prof | Out-Null
        $argList = @(
            "--remote-debugging-port=$Port",
            "--user-data-dir=$Prof",
            '--no-first-run',
            '--no-default-browser-check',
            '--disable-sync',
            '--disable-features=msEdgeWelcomePage,msEdgeIdentityFeature',
            '--window-size=1150,820',
            $Url
        )
        Write-Log "启动浏览器：$edge  （调试端口 $Port）"
        Start-Process -FilePath $edge -ArgumentList $argList | Out-Null
        for ($i = 0; $i -lt 30; $i++) {
            Start-Sleep -Milliseconds 600
            $json = Get-CdpJson $Port
            if ($json) { break }
        }
    }
    if (-not $json) { Write-Log '浏览器调试端口未就绪' 'WARN'; return $null }
    try { $list = $json | ConvertFrom-Json } catch { return $null }
    $pages = @($list | Where-Object { $_.type -eq 'page' -and $_.webSocketDebuggerUrl })
    if ($pages.Count -eq 0) { Write-Log '没有可用的浏览器页面目标' 'WARN'; return $null }
    # 优先选门户页；否则选第一个不是 edge:// 内部页的普通页面
    $page = @($pages | Where-Object { $_.url -like "*$PortalHost*" }) | Select-Object -First 1
    if (-not $page) { $page = @($pages | Where-Object { $_.url -notlike 'edge://*' -and $_.url -notlike 'chrome://*' }) | Select-Object -First 1 }
    if (-not $page) { $page = $pages[0] }
    return @{ WsUrl = $page.webSocketDebuggerUrl; PageUrl = $page.url }
}

# 通过 CDP 在页面里执行 JS，返回表达式的结果字符串
function Invoke-CdpEvaluate {
    param([string]$WsUrl, [string]$Expression, [int]$TimeoutSec = 90)
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $cts = New-Object System.Threading.CancellationTokenSource
    $cts.CancelAfter($TimeoutSec * 1000)
    $tok = $cts.Token
    try {
        $ws.ConnectAsync([Uri]$WsUrl, $tok).GetAwaiter().GetResult() | Out-Null
        $payload = @{
            id     = 1
            method = 'Runtime.evaluate'
            params = @{ expression = $Expression; awaitPromise = $true; returnByValue = $true; userGesture = $true }
        }
        $bytes = [Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Depth 8 -Compress))
        $seg   = New-Object 'System.ArraySegment[byte]' -ArgumentList (, $bytes)
        $ws.SendAsync($seg, [Net.WebSockets.WebSocketMessageType]::Text, $true, $tok).GetAwaiter().GetResult() | Out-Null

        $buf = New-Object byte[] 262144
        $sb  = New-Object Text.StringBuilder
        while ($true) {
            $seg2 = New-Object 'System.ArraySegment[byte]' -ArgumentList (, $buf)
            $res  = $ws.ReceiveAsync($seg2, $tok).GetAwaiter().GetResult()
            if ($res.MessageType -eq [Net.WebSockets.WebSocketMessageType]::Close) { return $null }
            [void]$sb.Append([Text.Encoding]::UTF8.GetString($buf, 0, $res.Count))
            if ($res.EndOfMessage) {
                $raw = $sb.ToString()
                [void]$sb.Clear()
                try { $obj = $raw | ConvertFrom-Json } catch { continue }
                if ($obj.id -eq 1) {
                    # 页面里 JS 抛异常时要把错误暴露出来，否则只能看到一个空值
                    if ($obj.result -and $obj.result.exceptionDetails) {
                        $ex = $obj.result.exceptionDetails
                        $msg = $ex.text
                        try { if ($ex.exception.description) { $msg = $ex.exception.description } } catch { }
                        return "JS-EXCEPTION: $msg"
                    }
                    if ($obj.error) { return ("CDP-ERROR: " + ($obj.error | ConvertTo-Json -Depth 5 -Compress)) }
                    if ($obj.result -and $obj.result.result -and ($obj.result.result.PSObject.Properties.Name -contains 'value')) {
                        return [string]$obj.result.result.value
                    }
                    return ($obj | ConvertTo-Json -Depth 8 -Compress)
                }
            }
        }
    } catch {
        return "CDP-EXC: $($_.Exception.Message)"
    } finally {
        try { $ws.Dispose() } catch { }
        try { $cts.Dispose() } catch { }
    }
}

# 页面里的自动填表脚本（__XXX__ 会被替换成 JSON 字符串）
$LoginJsTemplate = @'
(async () => {
  const ACCOUNT = __ACCOUNT__;
  const PASSWORD = __PASSWORD__;
  const CARRIER = __CARRIER__;
  const IPV4 = __IPV4__;
  const IPV6 = __IPV6__;
  const SUFFIX_MODE = __SUFFIX_MODE__;
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const out = { ok:false, step:'start', url:location.href, title:document.title, notes:[] };

  // ---------- 网络探针：记录门户自己发出的所有请求 ----------
  window.__net = [];
  try {
    const oOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function (m, u) { try { window.__net.push('XHR ' + m + ' ' + u); } catch (e) {} return oOpen.apply(this, arguments); };
    if (window.fetch) {
      const oFetch = window.fetch;
      window.fetch = function (u) { try { window.__net.push('FETCH ' + (typeof u === 'string' ? u : (u && u.url))); } catch (e) {} return oFetch.apply(this, arguments); };
    }
    new MutationObserver(function (ms) {
      ms.forEach(function (m) { m.addedNodes.forEach(function (n) {
        if (n.tagName === 'SCRIPT' && n.src) window.__net.push('SCRIPT ' + n.src);
        if (n.tagName === 'IFRAME' && n.src) window.__net.push('IFRAME ' + n.src);
      }); });
    }).observe(document.documentElement, { childList:true, subtree:true });
  } catch (e) { out.notes.push('探针安装失败:' + e.message); }

  const setVal = (el, v) => {
    try { Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set.call(el, v); }
    catch (e) { el.value = v; }
    ['input','change','keyup','blur'].forEach(t => el.dispatchEvent(new Event(t, { bubbles:true })));
  };

  // ---------- 1. 找“真正要提交的那个表单” ----------
  // 关键教训：不能用 document.querySelector 全局抓输入框——页面上有 f1~f5 多个表单，
  // 全局第一个 upass 未必属于提交用的表单，会填到一个"看不见的表单"里，
  // 结果提交出去的 upass 是空的（AC 报 ldap auth error）。
  const isVisible = el => !!(el && el.type !== 'hidden' && (el.offsetParent !== null || el.getClientRects().length > 0));
  const pickForm = () => {
    const all = Array.from(document.querySelectorAll('form'));
    for (const f of all) {                       // 优先：账号+密码都可见的表单
      const a = f.querySelector('input[name="DDDDD"]'), p = f.querySelector('input[name="upass"]');
      if (a && p && isVisible(a) && isVisible(p)) return f;
    }
    for (const f of all) {                       // 其次：任意含账号+密码的表单
      const a = f.querySelector('input[name="DDDDD"]'), p = f.querySelector('input[name="upass"]');
      if (a && p) return f;
    }
    return window.f1 || document.forms[0] || null;
  };
  for (let i = 0; i < 60; i++) {
    if (document.querySelector('input[name="upass"]')) { out.notes.push('表单出现 耗时' + (i * 500) + 'ms'); break; }
    await sleep(500);
  }
  const form = pickForm();
  if (!form) { out.step = 'form-not-found'; return JSON.stringify(out); }
  out.formName = form.name || form.id || '(无名)';
  out.formCount = document.querySelectorAll('form').length;
  out.step = 'form-found';

  const acc = form.querySelector('input[name="DDDDD"]');
  const pwd = form.querySelector('input[name="upass"]');
  if (!acc || !pwd) {
    out.step = 'input-not-found';
    out.formHtml = (form.innerHTML || '').replace(/\s+/g, ' ').slice(0, 300);
    return JSON.stringify(out);
  }

  // ---------- 2. 填账号 / 密码（只在选中表单内部操作）----------
  acc.focus(); setVal(acc, ACCOUNT);
  pwd.focus(); setVal(pwd, PASSWORD);
  out.notes.push('表单=' + out.formName + ' 账号=' + acc.value + ' 密码长度=' + pwd.value.length);
  if (pwd.value.length === 0) {
    // 双保险：原生 setter 没生效就用直接赋值再来一次
    pwd.value = PASSWORD;
    pwd.dispatchEvent(new Event('input', { bubbles:true }));
    pwd.dispatchEvent(new Event('change', { bubbles:true }));
    out.notes.push('密码用直接赋值补了一次，长度=' + pwd.value.length);
  }

  // ---------- 3. 选运营商（点“中国移动”）----------
  out.isp = 'none';
  const radios = Array.from(document.querySelectorAll('div[name="ISP_radio"] input[name="network"], input[name="network"]'));
  if (radios.length) {
    let target = null;
    for (const r of radios) {
      let txt = '';
      if (r.id) { const l = document.querySelector('label[for="' + r.id + '"]'); if (l) txt += l.textContent; }
      let p = r.parentElement, d = 0;
      while (p && d < 4) { txt += ' ' + (p.textContent || ''); p = p.parentElement; d++; }
      if (txt.indexOf(CARRIER) >= 0) { target = r; break; }
    }
    if (!target) { for (const r of radios) { if (['@cmcc','cmcc','2'].indexOf(String(r.value)) >= 0) { target = r; break; } } }
    if (!target) target = radios[0];
    target.click(); target.checked = true;
    target.dispatchEvent(new Event('change', { bubbles:true }));
    out.isp = 'radio value=' + target.value;
  } else {
    const sel = document.querySelector('select[name="ISP_select"]');
    if (sel) {
      for (const o of sel.options) { if ((o.textContent || '').indexOf(CARRIER) >= 0) { sel.value = o.value; break; } }
      sel.dispatchEvent(new Event('change', { bubbles:true }));
      out.isp = 'select value=' + sel.value;
    }
  }

  // ---------- 4. 勾免责声明（不勾登录会被拦下）----------
  const c1 = document.querySelector('input[name="C1"]');
  if (c1 && !c1.checked) {
    c1.click(); c1.checked = true;
    c1.dispatchEvent(new Event('change', { bubbles:true }));
    out.notes.push('已勾选免责声明 C1');
  }

  // ---------- 5. 关键：把本机 IP 写进门户的 term 对象 ----------
  // 门户 ee() 里：term.enablev6 && term.ipv6=="" && term.checkipv6==1 时会静默 return false，
  // 表现就是“点了登录按钮毫无反应、一个请求都不发”。这里直接把本机 IPv6 补上。
  try {
    if (typeof term !== 'undefined' && term) {
      out.termBefore = { ip: term.ip, ipv6: term.ipv6, enablev6: term.enablev6, checkipv6: term.checkipv6 };
      if (IPV4) term.ip = IPV4;
      if (IPV6) term.ipv6 = IPV6;
      out.termAfter = { ip: term.ip, ipv6: term.ipv6 };
    } else { out.notes.push('页面里没有 term 对象'); }
  } catch (e) { out.notes.push('设置 term 失败:' + e.message); }
  if (typeof jsVersion === 'undefined') {
    try { window.jsVersion = (typeof fileVersion !== 'undefined' ? fileVersion : '4.X'); out.notes.push('已补齐 jsVersion'); } catch (e) {}
  }

  await sleep(300);

  // ---------- 6. 提交 ----------
  // 后缀模式：
  //   none   = 纯账号 2500220712，不拼 @cmcc
  //   portal = 走门户自己的 login.init（门户会把下拉框的值当后缀拼上去 => 2500220712@cmcc）
  let submitted = false;

  // 提交前最后一次校验：账号/密码必须真的在 login.form 里，否则提交出去是空密码
  login.form = form;
  const checkAcc = form.querySelector('input[name="DDDDD"]');
  const checkPwd = form.querySelector('input[name="upass"]');
  if (checkAcc) setVal(checkAcc, ACCOUNT);
  if (checkPwd) setVal(checkPwd, PASSWORD);
  out.submitCheck = {
    form: form.name || form.id || '(无名)',
    account: checkAcc ? checkAcc.value : null,
    passLen: checkPwd ? checkPwd.value.length : -1
  };
  if (!checkPwd || out.submitCheck.passLen === 0) { out.step = 'pass-empty-abort'; return JSON.stringify(out); }

  if (SUFFIX_MODE === 'none' && typeof login !== 'undefined' && login && typeof login.default_login === 'function') {
    try {
      login.account = ACCOUNT;            // 纯账号，不带后缀
      login.tempAccountSuffix = '';       // 明确清空后缀
      login.default_login();              // 直接提交，绕开 setISP() 的拼接
      out.step = 'default_login(无后缀账号=' + login.account + ')';
      submitted = true;
    } catch (e) { out.notes.push('无后缀提交失败，回退门户方式:' + e.message); }
  }

  if (!submitted) {
    try {
      if (typeof login !== 'undefined' && login && typeof login.init === 'function') {
        login.init(form);
        out.step = 'login.init(门户按下拉框拼后缀)';
      } else {
        const btn = document.querySelector('input[name="0MKKey"]') || document.querySelector('input[type=submit], button[type=submit]');
        if (btn) { btn.click(); out.step = 'clicked-submit'; }
        else { form.submit(); out.step = 'form.submit'; }
      }
    } catch (e) { out.step = 'submit-error:' + e.message; }
  }

  out.ok = true;
  await sleep(8000);
  out.net = window.__net.slice(0, 12);
  out.pageText = (document.body.innerText || '').replace(/\s+/g, ' ').slice(0, 260);
  out.afterUrl = location.href;
  out.afterTitle = document.title;
  return JSON.stringify(out);
})()

'@

# 完整走一遍浏览器登录
function Invoke-BrowserLogin {
    param([string]$CarrierName, [string]$Ip6 = '', [string]$SuffixMode = 'none')
    $t = Start-AutomationBrowser -Port $CdpPort -Prof $ProfileDir -Url $PortalUrl
    if (-not $t) { return @{ Ok = $false; Info = '浏览器启动失败' } }

    # 如果当前页面不是门户，先导航过去
    if ($t.PageUrl -notlike "*$PortalHost*") {
        [void](Invoke-CdpEvaluate -WsUrl $t.WsUrl -Expression "location.href='$PortalUrl'; 'navigating'" -TimeoutSec 20)
        Start-Sleep -Seconds 4
    }

    $js = $LoginJsTemplate.Replace('__ACCOUNT__',  (ConvertTo-Json $Account  -Compress))
    $js = $js.Replace('__PASSWORD__', (ConvertTo-Json $Password -Compress))
    $js = $js.Replace('__SUFFIX_MODE__', (ConvertTo-Json $SuffixMode -Compress))
    $js = $js.Replace('__CARRIER__',  (ConvertTo-Json $CarrierName -Compress))
    $js = $js.Replace('__IPV4__',     (ConvertTo-Json (Get-LocalIPv4) -Compress))
    $js = $js.Replace('__IPV6__',     (ConvertTo-Json $Ip6 -Compress))

    Write-Log '已连接浏览器，正在填写登录表单…'
    $result = Invoke-CdpEvaluate -WsUrl $t.WsUrl -Expression $js -TimeoutSec 120
    Write-Log "浏览器自动化返回：$result"

    if (-not $result) { return @{ Ok = $false; Info = '自动化脚本无返回' } }
    if ($result -like 'CDP-EXC:*' -or $result -like 'JS-EXCEPTION:*') { return @{ Ok = $false; Info = $result } }

    # 提交后轮询状态，最多等 45 秒
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 3
        $st = Get-PortalStatus
        if ($st.Online -eq $true) { return @{ Ok = $true; Info = "已在线 uid=$($st.Uid)" } }
    }
    return @{ Ok = $false; Info = "提交后仍未在线（脚本返回：$result）" }
}

# ================================ 主流程 ================================
Write-Log '==================== 门户自动登录启动 ===================='
Write-Log "账号=$Account  通道=$Carrier  门户=$PortalUrl  脚本目录=$ScriptDir"

if (-not $CarrierMap.ContainsKey($Carrier)) {
    Write-Log "配置错误：通道 '$Carrier' 无效，可选值：$($CarrierMap.Keys -join ' / ')" 'ERROR'
    exit 2
}
$suffix = $CarrierMap[$Carrier]
$userNoSuffix = $Account                       # 纯账号
$userPortal   = $Account + $suffix             # 门户按下拉框拼后缀后的账号
Write-Log "账号='$Account'  通道='$Carrier'  后缀模式=$SuffixMode"
Write-Log "  · 纯账号方式将提交：'$userNoSuffix'"
Write-Log "  · 门户拼接方式将提交：'$userPortal'（后缀由门户的 setISP 逻辑加上，不是脚本加的）"

if ($StatusOnly) {
    $st = Get-PortalStatus
    Write-Log "状态检测：Online=$($st.Online)  Uid=$($st.Uid)"
    Write-Log "本机 IPv4 = $(Get-LocalIPv4)   门户端口80可达 = $(Test-PortalReachable)"
    Write-Log "本机 IPv6 候选 = $((@(Get-LocalIPv6List)) -join ' , ')"
    Write-Log "门户页标记 = Dr.COMWebLoginID_$(Invoke-PortalPrime).htm"
    Write-Log "浏览器 = $(Get-EdgePath)"
    exit 0
}

if ($Logout) {
    Write-Log '【自测】正在注销当前认证...'
    Write-Log "注销返回：$(Invoke-PortalGet "http://$PortalHost/drcom/logout?callback=cb" 15)"
    Start-Sleep -Seconds 3
    Write-Log "注销后状态：Online=$((Get-PortalStatus).Online)"
    Write-Log '【自测】已注销。请再运行一次本程序，或直接双击 Test-AutoLogin.cmd。'
    exit 0
}

if ($TestBrowser) {
    Write-Log "浏览器 = $(Get-EdgePath)"
    $t = Start-AutomationBrowser -Port $CdpPort -Prof $ProfileDir -Url $PortalUrl
    if (-not $t) { Write-Log '浏览器自动化通道不可用' 'ERROR'; exit 1 }
    Write-Log "已连接：$($t.WsUrl)"
    $js = @'
(async () => {
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const info = { url: location.href, title: document.title, ready: document.readyState, notes: [] };
  for (let i = 0; i < 20; i++) {
    if (document.querySelector('input[name="DDDDD"]')) break;
    await sleep(500);
  }
  info.hasAccountInput = !!document.querySelector('input[name="DDDDD"]');
  info.hasPassInput    = !!document.querySelector('input[name="upass"]');
  info.hasLoginButton  = !!document.querySelector('input[name="0MKKey"]');
  info.ispRadios       = Array.from(document.querySelectorAll('input[name="network"]')).map(r => (r.value + '|' + ((r.parentElement && r.parentElement.textContent) || '').trim().slice(0,12)));
  info.ispSelect       = !!document.querySelector('select[name="ISP_select"]');
  info.disclaimer      = !!document.querySelector('input[name="C1"]');
  return JSON.stringify(info);
})()
'@
    Write-Log "页面探测返回：$(Invoke-CdpEvaluate -WsUrl $t.WsUrl -Expression $js -TimeoutSec 40)"
    exit 0
}

$success = $false
$lastMsg = ''
$browserStarted = $false

for ($i = 1; $i -le $MaxTry; $i++) {

    if (-not (Test-PortalReachable)) {
        Write-Log "第 $i/$MaxTry 轮：门户 $PortalHost:80 暂不可达，${RetryDelay}s 后重试" 'WARN'
        Start-Sleep -Seconds $RetryDelay
        continue
    }

    if (-not $Force) {
        $st = Get-PortalStatus
        if ($st.Online -eq $true) {
            Write-Log "检测到网络已在线（uid=$($st.Uid)），无需登录"
            $success = $true
            break
        }
    }

    # ---- 先预热门户页 ----
    $marker = Invoke-PortalPrime
    if ($marker) { Write-Log "第 $i/$MaxTry 轮：已预热门户页（Dr.COMWebLoginID_$marker.htm）" }

    # ---- 本轮用哪种账号写法 ----
    # none -> 纯账号；portal -> 门户按下拉框拼后缀；auto -> 单数轮用 none，双数轮用 portal
    if ($SuffixMode -eq 'none')        { $mode = 'none' }
    elseif ($SuffixMode -eq 'portal')  { $mode = 'portal' }
    else                               { $mode = if ($i % 2 -eq 1) { 'none' } else { 'portal' } }
    $userNow = if ($mode -eq 'none') { $userNoSuffix } else { $userPortal }

    # ---- 方式 B（主力）：驱动浏览器 —— 与手动登录完全等价，最可靠 ----
    if (-not $NoBrowser) {
        $browserStarted = $true
        $ips6 = @(Get-LocalIPv6List)
        $bIp6 = if ($ips6.Count -gt 0) { $ips6[($i - 1) % $ips6.Count] } else { '' }
        Write-Log "第 $i/$MaxTry 轮：浏览器方式（账号写法=$mode 提交账号='$userNow'  IPv4=$(Get-LocalIPv4)  IPv6=$bIp6）"
        $b = Invoke-BrowserLogin -CarrierName $Carrier -Ip6 $bIp6 -SuffixMode $mode
        if ($b.Ok) {
            Write-Log "浏览器登录成功：$($b.Info)"
            $success = $true
            break
        }
        $lastMsg = $b.Info
        Write-Log "第 $i/$MaxTry 轮：浏览器登录未成功 — $($b.Info)" 'WARN'
    } else {
        $lastMsg = '已用 -NoBrowser 禁用浏览器方式'
        Write-Log $lastMsg 'WARN'
    }

    # ---- 方式 A（备用）：HTTP 直接登录 ----
    if (-not $NoHttp -and -not $success) {
        $md5Flag = Get-PortalMd5Flag
        $ips6    = @(Get-LocalIPv6List)
        $ip6     = if ($ips6.Count -gt 0) { $ips6[($i - 1) % $ips6.Count] } else { '' }
        $r = Invoke-PortalLogin -User $userNow -UseMd5 ([bool]($md5Flag -eq 1)) -Ip6 $ip6
        Write-Log "第 $i/$MaxTry 轮：HTTP 备用方式（账号='$userNow' v6ip=$ip6）返回 $($r.Message)"
        if ($r.Ok -or $r.Message -match '(?i)clientip\s+online') {
            Start-Sleep -Seconds 3
            if ((Get-PortalStatus).Online -eq $true) {
                Write-Log 'HTTP 备用方式登录成功'
                $success = $true
                break
            }
        }
        $lastMsg = $r.Message
    }

    Start-Sleep -Seconds $RetryDelay
}

$final = Get-PortalStatus
Write-Log "最终状态：Online=$($final.Online)  Uid=$($final.Uid)"

if ($final.Online -eq $true) {
    Write-Log '结果：认证成功，网络已通畅'
    $success = $true
} else {
    Write-Log "结果：认证未成功，最后信息：$lastMsg" 'ERROR'
}

# 浏览器处理：自动化开的浏览器已经停在门户页，就不用再开一个
if ($OpenBrowser -and -not $NoBrowser) {
    if (-not $browserStarted) {
        if (Test-PortalReachable) {
            try { Start-Process $PortalUrl; Write-Log "已打开浏览器：$PortalUrl" }
            catch { Write-Log "打开浏览器失败：$($_.Exception.Message)" 'WARN' }
        } else {
            Write-Log '门户不可达，跳过打开浏览器' 'WARN'
        }
    } else {
        Write-Log '浏览器窗口已打开在门户页'
    }
}

Write-Log '==================== 门户自动登录结束 ===================='

if ($success) { exit 0 } else { exit 1 }
