' 班主任工作台 - 创建桌面快捷方式
' 双击运行此文件，会在桌面创建带图标的快捷方式

Set ws = CreateObject("WScript.Shell")
desktopPath = ws.SpecialFolders("Desktop")
' 获取当前脚本所在目录
Set fso = CreateObject("Scripting.FileSystemObject")
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

' 快捷方式路径
shortcutPath = desktopPath & "\班主任工作台.lnk"

' 创建快捷方式
Set shortcut = ws.CreateShortcut(shortcutPath)
shortcut.TargetPath = currentDir & "\班主任工作台.bat"
shortcut.WorkingDirectory = currentDir
shortcut.IconLocation = currentDir & "\workbench-icon-photo.ico, 0"
shortcut.Description = "班主任管理工作台 - 智能数据管家"
shortcut.WindowStyle = 7  ' 最小化窗口（bat 窗口）
shortcut.Save

' 提示
MsgBox "桌面快捷方式已创建！" & vbCrLf & vbCrLf & _
       "图标: " & currentDir & "\workbench-icon-photo.ico" & vbCrLf & _
       "程序: " & currentDir & "\班主任工作台.bat" & vbCrLf & vbCrLf & _
       "双击桌面""班主任工作台""即可打开。", vbInformation, "创建成功"
