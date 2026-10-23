# 校园网门户自动登录（开机自启动）

开机登录 Windows 后**自动完成** `http://10.0.1.5/` 的宽带认证，浏览器停在门户页。

---

## 一、文件说明

| 文件 | 作用 |
| --- | --- |
| `AutoLogin.ps1` | 主程序：检测在线 → 驱动浏览器自动填表登录 → 重试 → 写日志 |
| `AutoLogin.vbs` | 静默启动器（**开机自启动调用的是它**，不闪黑窗口） |
| `Login-Now.cmd` | 手动运行一次（显示结果窗口，日常用这个） |
| `Test-AutoLogin.cmd` | **自测用**：先注销（断网）再自动登录，验证真的能登回来 |
| `AutoLogin.log` | 运行日志（自动生成，超过 512KB 自动清理） |

**开机自启动项**（只新增了这一个快捷方式，没有改动其它任何文件）：

```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Portal-AutoLogin.lnk
→ wscript.exe "D:\codex\PortalAutoLogin\AutoLogin.vbs"
```

---

## 二、当前配置

| 项目 | 值 |
| --- | --- |
| 门户网址 | `http://10.0.1.5/` |
| 账号 | `2500220712` |
| 密码 | `12345678Hua.` |
| 通道 | **中国移动**（账号后缀 `@cmcc`） |

---

## 三、工作原理（重要）

门户（Dr.COM 哆点，桂林电子科技大学）的 HTTP 登录接口 `/drcom/login`
**离线时很不稳定**——实测经常连续返回 `203 Bad request(2)`，靠它反复重试很不可靠。

所以程序采用**浏览器优先**策略，也就是把"人工点一遍"自动化：

```
开机登录 Windows
   └─ 启动项触发 AutoLogin.vbs（无窗口）
        └─ powershell.exe 运行 AutoLogin.ps1
             ├─ 1. GET /drcom/chkstatus —— 已在线？直接收工
             ├─ 2. GET http://10.0.1.5/ 预热门户页
             ├─ 3. 【主力】启动 Edge（独立配置 + 调试端口 19222）
             │      └─ 通过 DevTools 协议在页面里执行脚本：
             │           填账号 2500220712
             │           填密码
             │           点选「中国移动」
             │           勾选免责声明（若有）
             │           点登录按钮（走门户自己的提交逻辑）
             │      └─ 轮询 chkstatus，最多等 45 秒确认上线
             ├─ 4. 【备用】若浏览器方式失败，再用 HTTP 接口方式试一次
             └─ 5. 失败则每 10 秒重试，最多 12 轮
```

### 关于「选择中国移动」

该门户（`enable_r3 = 0`）在网页上点选运营商后，是把它作为**账号后缀**拼接：

| 通道 | 后缀 | 实际提交账号 |
| --- | --- | --- |
| 校园网 | （无） | `2500220712` |
| **中国移动** | `@cmcc` | `2500220712@cmcc` |
| 中国联通 | `@unicom` | `2500220712@unicom` |
| 中国电信 | `@telecom` | `2500220712@telecom` |

程序会自动找到界面上写着「中国移动」的单选按钮并点它（等价于手动操作）。

### 关于那个自动打开的 Edge 窗口

自动化用的是**独立配置文件**：

```
%LOCALAPPDATA%\PortalAutoLogin\edge-profile
```

（Edge 136+ 要求开调试端口必须用非默认配置目录。）
它只用来过认证，**不影响你平时用的 Edge**。认证是按 IP/MAC 走的，
登进去之后整个系统都能上网，这个窗口关掉也没事。

---

## 四、修改账号 / 密码 / 通道

用记事本打开 `AutoLogin.ps1`，只改最上面【配置区】这几行，保存即可：

```powershell
$Account      = '2500220712'      # 账号
$Password     = '12345678Hua.'    # 密码
$Carrier      = '中国移动'         # 校园网 / 中国移动 / 中国联通 / 中国电信
$MaxTry       = 12                # 最多尝试轮数
$RetryDelay   = 10                # 每轮失败后等待秒数
$OpenBrowser  = $true             # 完成后是否打开浏览器
```

> ⚠️ 修改后请**另存为 UTF-8 编码**，否则中文会乱码。

---

## 五、自测方法（重要）

想确认它真能从「离线」自动登回来，直接**双击 `Test-AutoLogin.cmd`**：

```
STEP 1/2 : 注销（故意断网几秒）
STEP 2/2 : 自动登录（模拟开机时的行为）
```

看最后一行 `ExitCode = 0` 即为成功。细节看 `AutoLogin.log`。

期望日志：

```
[INFO] 第 1/12 轮：已预热门户页（Dr.COMWebLoginID_0.htm）
[INFO] 已连接浏览器，正在填写登录表单…
[INFO] 浏览器自动化返回：{"ok":true,"step":"clicked-submit","isp":"选中 value=@cmcc", ...}
[INFO] 浏览器登录成功：已在线 uid=2500220712@cmcc
```

---

## 六、常用命令

```powershell
.\Login-Now.cmd                                    # 手动登录一次
.\Test-AutoLogin.cmd                               # 自测：注销 + 自动登回

# 只看状态（不登录）
powershell -NoProfile -ExecutionPolicy Bypass -File .\AutoLogin.ps1 -StatusOnly

# 只测浏览器自动化通道（会开一个浏览器窗口，不提交登录）
powershell -NoProfile -ExecutionPolicy Bypass -File .\AutoLogin.ps1 -TestBrowser

# 只用接口方式，不开浏览器
powershell -NoProfile -ExecutionPolicy Bypass -File .\AutoLogin.ps1 -NoBrowser

# 只走浏览器，跳过接口备用方式
powershell -NoProfile -ExecutionPolicy Bypass -File .\AutoLogin.ps1 -NoHttp

# 只注销
powershell -NoProfile -ExecutionPolicy Bypass -File .\AutoLogin.ps1 -Logout
```

退出码：`0` = 认证成功或已在线；`1` = 认证失败；`2` = 配置错误。

---

## 七、关闭 / 恢复开机自启动

删除下面这一个快捷方式即可，其余文件删不删都行：

```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Portal-AutoLogin.lnk
```

快速打开该目录：`Win + R` → 输入 `shell:startup` → 回车。

---

## 八、技术要点（踩过的坑）

1. **`0MKKey` 选择器必须带引号**：`input[name="0MKKey"]`。
   CSS 属性选择器的值若以数字开头不加引号，浏览器会抛
   `not a valid selector`，导致自动化静默失败。
2. **门户登录页是 JS 动态渲染的**：离线页面 HTML（`Dr.COMWebLoginID_0.htm`
   「上网登录页」）里**没有任何 form/input**，所以必须等页面渲染完再填表。
3. **登录参数必须带 `v6ip`**：门户 `default_login` 会同时提交 `v4ip`(IPv4) 和
   `v6ip`(IPv6)。本机有多个全局 IPv6，程序会轮换重试。
4. **不要附加 `jsVersion` 参数**，加了会走另一条分支并返回 203。
5. **HTTP 接口离线时不可靠**：多次实测连续返回 `203 Bad request(2)`，
   偶尔又能成功——所以只当备用，主力靠浏览器自动化。
6. **密码是明文提交**（门户 `en_md5=0`），`AutoLogin.ps1` 里存的是明文密码。

---

## 九、排错

1. 先看 `AutoLogin.log`，里面有每一步的原始返回。
2. 手动跑 `Login-Now.cmd` 可以直接看到输出。
3. `-TestBrowser` 会打印页面探测结果（表单在不在、有哪些运营商选项），
   是排查浏览器自动化最直接的手段。
4. 常见返回含义：
   - `"result":1` → 认证成功。
   - `"msga":"clientip online"` → 本机 IP 已在线，视为成功。
   - `203 Bad request(2)` → HTTP 接口被拒（已改为备用方式，不影响）。
   - `JS-EXCEPTION:` → 页面脚本报错，日志里会带具体原因。
   - `form-not-found` → 页面上没找到登录表单（通常表示其实已经在线了）。
