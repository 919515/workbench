-- 班主任工作台 - Mac 安装脚本
-- 使用方法：用"脚本编辑器"App打开此文件，点击运行按钮

-- 1. 找到脚本所在目录
set scriptPath to POSIX path of (path to me)
-- 用 Python 获取目录，避免 dirname 处理中文路径的问题
set scriptDir to do shell script "python3 -c \"import os,sys; print(os.path.dirname(os.path.realpath(sys.argv[1])))\" " & quoted form of scriptPath

-- 2. 定义路径
set desktopPath to POSIX path of (path to desktop)
set appPath to desktopPath & "班主任工作台.app"
set contentsPath to appPath & "/Contents"
set macOSPath to contentsPath & "/MacOS"
set resourcesPath to contentsPath & "/Resources"

-- 3. 清理旧的
do shell script "rm -rf " & quoted form of appPath

-- 4. 创建目录
do shell script "mkdir -p " & quoted form of macOSPath
do shell script "mkdir -p " & quoted form of resourcesPath

-- 5. 复制文件（逐个复制，带错误检查）
set htmlSrc to scriptDir & "/bzr-workbench-desktop.html"
set iconSrc to scriptDir & "/workbench-icon-photo.png"
set htmlDst to resourcesPath & "/workbench.html"
set iconDst to resourcesPath & "/icon.png"

try
	do shell script "cp " & quoted form of htmlSrc & " " & quoted form of htmlDst
on error
	display dialog "找不到 bzr-workbench-desktop.html 文件！

请确认以下文件都放在同一个文件夹中：
1. 安装工作台.applescript
2. bzr-workbench-desktop.html
3. workbench-icon-photo.png

当前查找目录：" & scriptDir with title "文件缺失" buttons {"确定"} default button 1
	return
end try

try
	do shell script "cp " & quoted form of iconSrc & " " & quoted form of iconDst
on error
	-- 图标缺失不中断，继续安装
end try

-- 6. 生成图标（用 Python 避免 sips 路径问题）
try
	do shell script "python3 -c \"import subprocess,os; d='" & resourcesPath & "/icon.iconset'; os.makedirs(d,exist_ok=True); [subprocess.run(['sips','-z',str(s),str(s),'" & iconDst & "','--out',f'{d}/icon_{s}x{s}.png'],capture_output=True) for s in [16,32,64,128,256,512]]; [subprocess.run(['sips','-z',str(s*2),str(s*2),'" & iconDst & "','--out',f'{d}/icon_{s}x{s}@2x.png'],capture_output=True) for s in [16,32,64,128,256,512]]\""
	do shell script "iconutil -c icns " & quoted form of (resourcesPath & "/icon.iconset") & " -o " & quoted form of (resourcesPath & "/icon.icns")
	do shell script "rm -rf " & quoted form of (resourcesPath & "/icon.iconset")
on error errMsg number errNum
	-- 图标失败不中断
	try
		do shell script "rm -rf " & quoted form of (resourcesPath & "/icon.iconset")
	end try
end try

-- 7. 写入启动脚本
set launchContent to "#!/bin/bash" & ASCII character 10
set launchContent to launchContent & "# 班主任工作台启动器" & ASCII character 10
set launchContent to launchContent & "APP_DIR=\"$(dirname \"$0\")/..\"" & ASCII character 10
set launchContent to launchContent & "HTML_FILE=\"$APP_DIR/Resources/workbench.html\"" & ASCII character 10
set launchContent to launchContent & "if [ -f \"$HTML_FILE\" ]; then" & ASCII character 10
set launchContent to launchContent & "  if [ -d \"/Applications/Google Chrome.app\" ]; then" & ASCII character 10
set launchContent to launchContent & "    open -a \"Google Chrome\" \"file://$HTML_FILE\"" & ASCII character 10
set launchContent to launchContent & "  elif [ -d \"/Applications/Microsoft Edge.app\" ]; then" & ASCII character 10
set launchContent to launchContent & "    open -a \"Microsoft Edge\" \"file://$HTML_FILE\"" & ASCII character 10
set launchContent to launchContent & "  elif [ -d \"/Applications/Safari.app\" ]; then" & ASCII character 10
set launchContent to launchContent & "    open -a \"Safari\" \"file://$HTML_FILE\"" & ASCII character 10
set launchContent to launchContent & "  else" & ASCII character 10
set launchContent to launchContent & "    open \"file://$HTML_FILE\"" & ASCII character 10
set launchContent to launchContent & "  fi" & ASCII character 10
set launchContent to launchContent & "else" & ASCII character 10
set launchContent to launchContent & "  osascript -e 'display dialog \"工作台文件缺失，请重新安装。\" with title \"错误\" buttons {\"确定\"} default button 1'" & ASCII character 10
set launchContent to launchContent & "fi" & ASCII character 10

set launchFilePath to macOSPath & "/launch.sh"
set launchFile to open for access (POSIX file launchFilePath) with write permission
set eof of launchFile to 0
write launchContent to launchFile
close access launchFile
do shell script "chmod +x " & quoted form of launchFilePath

-- 8. 写入 Info.plist
set plistContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" & ASCII character 10
set plistContent to plistContent & "<plist version=\"1.0\">" & ASCII character 10
set plistContent to plistContent & "<dict>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleName</key><string>班主任工作台</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleDisplayName</key><string>班主任工作台</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleExecutable</key><string>launch.sh</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleIdentifier</key><string>com.bzr.workbench</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleVersion</key><string>1.0</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundlePackageType</key><string>APPL</string>" & ASCII character 10
set plistContent to plistContent & "  <key>CFBundleIconFile</key><string>icon.icns</string>" & ASCII character 10
set plistContent to plistContent & "  <key>LSUIElement</key><true/>" & ASCII character 10
set plistContent to plistContent & "</dict>" & ASCII character 10
set plistContent to plistContent & "</plist>" & ASCII character 10

set plistFilePath to contentsPath & "/Info.plist"
set plistFile to open for access (POSIX file plistFilePath) with write permission
set eof of plistFile to 0
write plistContent to plistFile
close access plistFile

-- 9. 设置权限
do shell script "chmod -R 755 " & quoted form of appPath

-- 10. 刷新 Finder（让图标显示出来）
do shell script "touch " & quoted form of appPath

-- 11. 提示成功
display dialog "✅ 桌面快捷方式已创建！

桌面上已出现「班主任工作台」图标，双击即可打开。

如果双击提示无法打开：
右键点击图标 → 选择「打开」→ 点击「打开」确认即可。" with title "安装成功" buttons {"确定"} default button 1
