@echo off
chcp 65001 >nul
title 班主任管理工作台 - 手机版

:: 获取脚本所在目录
set "DIR=%~dp0"
set "HTML=%DIR%bzr-workbench-mobile.html"

:: 查找浏览器
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

:: 以手机模拟器模式启动
start "" "%BROWSER%" --app="file:///%HTML:\=/%" --window-size=400,800 --window-position=200,50
