'=============================================================
' Portal AutoLogin - silent launcher (used by the Startup item)
' Runs AutoLogin.ps1 in this folder with no visible window.
'=============================================================
Option Explicit
Dim fso, shell, baseDir, ps1, cmd
Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

baseDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1     = baseDir & "\AutoLogin.ps1"

If Not fso.FileExists(ps1) Then
    MsgBox "AutoLogin.ps1 not found:" & vbCrLf & ps1, 16, "Portal AutoLogin"
    WScript.Quit 1
End If

cmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"
' 0 = hidden window, False = do not wait
shell.Run cmd, 0, False
