#!/bin/bash
# 班主任工作台 - Mac 桌面快捷方式创建脚本
# 双击运行，会在桌面创建带图标的快捷方式

# 获取当前脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HTML_FILE="$SCRIPT_DIR/bzr-workbench-desktop.html"
ICON_FILE="$SCRIPT_DIR/workbench-icon-photo.png"
DESKTOP="$HOME/Desktop"

# 查找 Chrome
CHROME=""
if [ -d "/Applications/Google Chrome.app" ]; then
    CHROME="/Applications/Google Chrome.app"
elif [ -d "/Applications/Microsoft Edge.app" ]; then
    CHROME="/Applications/Microsoft Edge.app"
elif [ -d "/Applications/Chromium.app" ]; then
    CHROME="/Applications/Chromium.app"
elif [ -d "/Applications/Brave Browser.app" ]; then
    CHROME="/Applications/Brave Browser.app"
fi

if [ -z "$CHROME" ]; then
    osascript -e 'display dialog "未找到 Chrome 或 Edge 浏览器，请先安装。" with title "提示" buttons {"确定"} default button 1'
    exit 1
fi

# 创建 AppleScript 应用（.app）
APP_NAME="班主任工作台"
APP_PATH="$DESKTOP/$APP_NAME.app"

# 删除旧的
rm -rf "$APP_PATH"

# 用 osascript 创建 .app
osascript << APPLESCRIPT
set appPath to POSIX file "$APP_PATH"
tell application "Finder"
    set theApp to make new folder at (POSIX file "$DESKTOP" as alias) with properties {name:"$APP_NAME.app"}
end tell

-- 创建 Contents 目录结构
set contentsPath to "$APP_PATH/Contents"
do shell script "mkdir -p '" & contentsPath & "/MacOS'"
do shell script "mkdir -p '" & contentsPath & "/Resources'"
APPLESCRIPT

# 创建启动脚本
cat > "$APP_PATH/Contents/MacOS/run.sh" << EOF
#!/bin/bash
HTML="$HTML_FILE"
CHROME="$CHROME"
open -a "$CHROME" "file://$HTML"
EOF
chmod +x "$APP_PATH/Contents/MacOS/run.sh"

# 创建 Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>班主任工作台</string>
    <key>CFBundleDisplayName</key>
    <string>班主任工作台</string>
    <key>CFBundleExecutable</key>
    <string>run.sh</string>
    <key>CFBundleIdentifier</key>
    <string>com.bzr.workbench</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# 复制图标
if [ -f "$ICON_FILE" ]; then
    cp "$ICON_FILE" "$APP_PATH/Contents/Resources/icon.png"
fi

# 用 sips 生成 .icns 图标
if [ -f "$ICON_FILE" ]; then
    # 创建 iconset
    ICONSET="$APP_PATH/Contents/Resources/icon.iconset"
    mkdir -p "$ICONSET"
    for size in 16 32 64 128 256 512; do
        sips -z $size $size "$ICON_FILE" --out "$ICONSET/icon_${size}x${size}.png" > /dev/null 2>&1
        size2=$((size * 2))
        sips -z $size2 $size2 "$ICON_FILE" --out "$ICONSET/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    done
    iconutil -c icns "$ICONSET" -o "$APP_PATH/Contents/Resources/icon.icns" > /dev/null 2>&1
    rm -rf "$ICONSET"
fi

# 设置权限
chmod -R 755 "$APP_PATH"

# 提示成功
osascript -e "display dialog \"桌面快捷方式已创建！

双击桌面「班主任工作台」图标即可打开。

如果提示无法打开：
右键点击图标 → 选择「打开」→ 再次确认「打开」即可。\" with title \"创建成功\" buttons {\"确定\"} default button 1"

echo "Done!"
