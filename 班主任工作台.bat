@echo off
chcp 65001 >nul
title 班主任管理工作台

:: 获取脚本所在目录
set "DIR=%~dp0"
set "HTML=%DIR%bzr-workbench-desktop.html"

:: 查找浏览器（优先 Chrome，其次 Edge）
set "BROWSER="
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) else if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

if "%BROWSER%"=="" (
    echo 未找到 Chrome 或 Edge 浏览器，请先安装。
    pause
    exit /b 1
)

:: 以 App 模式启动（无浏览器边框，像独立应用一样）
start "" "%BROWSER%" --app="file:///%HTML:\=/%" --window-size=1400,900 --window-position=100,50
