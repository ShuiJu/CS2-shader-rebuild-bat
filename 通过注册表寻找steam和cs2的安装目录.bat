@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 初始化变量
set "steamPath="
set "cs2Path="

:: 1. 获取Steam安装路径（兼容32/64位系统）
for /f "tokens=2,*" %%A in (
        'reg query "HKLM\SOFTWARE\Wow6432Node\Valve\Steam" /v InstallPath 2^>nul ^| find "InstallPath"'
    ) do set "steamPath=%%B\steam.exe"

:: 2. 获取CS2路径（通过Steam库分析）
if exist "!steamPath!" (
    for %%A in ("!steamPath!") do (
        set "steamDir=%%~dpA"
        set "cs2Path=!steamDir!steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
    )
)

:: 3. 标准化路径格式（确保引号包裹）
set "steamPath="!steamPath!""
set "cs2Path="!cs2Path!""

:: 4. 写入日志文件（UTF-8编码）
echo --------------------------
echo Steam.exe路径：%steamPath%
echo cs2.exe路径：%cs2Path%
echo --------------------------

(
    echo %steamPath%
) > "%~dp0steamPath.log"

(
    echo %cs2Path%
) > "%~dp0cs2Path.log"

:: 5. 显示完成信息
echo.
echo Steam.exe路径已保存到: "%~dp0steamPath.log"
echo cs2.exe路径已保存到: "%~dp0cs2Path.log"
echo 按任意键退出...
pause >nul