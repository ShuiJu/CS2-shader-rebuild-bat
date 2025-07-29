@echo off
:: 设置UTF-8编码支持中文
chcp 65001 >nul
title CS2着色器缓存清理 ver 2025.07.30, 07:24
setlocal enabledelayedexpansion

:: 定义换行符（关键：两个空行不可删除）
set LF=^


:: 请求管理员权限
fltmc >nul 2>&1 || (
    echo [!] 正在请求管理员权限...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)
echo CS2着色器缓存清理 by 嗜金水狙 ver 2025.07.30, 07:24
:: 检查并读取log文件
set "useLogPaths="
if exist "%~dp0steamPath.log" (
    if not exist "%~dp0cs2Path.log" (
        goto :askPath
    )

    for %%F in ("%~dp0steamPath.log") do (
        if %%~zF LSS 1024 (
            echo.
            echo 检测到steamPath.log文件
            echo 文件内容：
            type "%~dp0steamPath.log"

            echo.
            echo 检测到cs2Path.log文件
            echo 文件内容：
            type "%~dp0cs2Path.log"
            
            set /p "confirm=是否使用此文件中的路径？[Y/n] (默认Y) "
            if /i "!confirm!"=="" set "confirm=Y"
            
            if /i "!confirm!"=="Y" (
                set "useLogPaths=1"
                set /p "steamPath=" < "%~dp0steamPath.log"
                set /p "cs2Path=" < "%~dp0cs2Path.log"
                
                :: 去除路径可能的引号
                set "steamPath=!steamPath:"=!"
                set "cs2Path=!cs2Path:"=!"
                
                echo.
                echo 已使用日志文件中的路径：
                echo Steam路径: !steamPath!
                echo CS2路径: !cs2Path!
                echo.
                @REM pause
                @REM timeout /t 3 >nul
            )
        )
    )
)

:: 如果没有使用日志路径，则询问用户输入
:askPath
if not defined useLogPaths (
    :: 询问 Steam 和 CS2 路径
    set "defaultSteamPath=C:\Program Files (x86)\Steam\steam.exe"
    @REM echo !defaultSteamPath!
    set "defaultCS2Path=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe"
    @REM echo !defaultCS2Path!

    echo 输入 Steam.exe 路径 [按下回车使用默认: !defaultSteamPath!]:
    set /p "steamPath="
    if "!steamPath!"=="" set "steamPath=!defaultSteamPath!"

    echo 输入 CS2.exe 路径 [按下回车使用默认: !defaultCS2Path!]:
    set /p "cs2Path="
    if "!cs2Path!"=="" set "cs2Path=!defaultCS2Path!"
)

:: 自动推导其他路径（修正版）
for %%A in ("%cs2Path%") do (
    set "cs2Dir=%%~dpA"
    :: 从 bin\win64\ 回退到 game\ 目录
    set "csgoPath=!cs2Dir:~0,-11!\csgo\"
    set "corePath=!cs2Dir:~0,-11!\csgo_core\"
)

:: 验证路径是否存在
if not exist "!csgoPath!" (
    echo 错误: 未找到CSGO目录: !csgoPath!
    pause
    exit /b
)
if not exist "!corePath!" (
    echo 错误: 未找到CORE目录: !corePath!
    pause
    exit /b
)

tasklist /FI "IMAGENAME eq cs2.exe" 2>nul | find /I "cs2.exe" >nul && (
    taskkill /F /IM cs2.exe >nul 2>&1 && (
        echo 没关游戏就来清理缓存？
    ) || (
        echo 没关游戏就来清理缓存？怎么你这cs2.exe我杀不掉？游戏关掉之后回到本窗口按下回车键。
        pause >nul
    )
)

@REM echo 删除着色器缓存前
@REM pause

:: 删除着色器缓存
echo 正在删除 %csgoPath% 和 %corePath% 中的着色器缓存文件...
del /q "%csgoPath%\shaders_*.vpk"
del /q "%corePath%\shaders_*.vpk"
if errorlevel 1 (
    echo 未找到着色器缓存文件。
)

:: 完整的DirectX缓存清理方案
echo.
echo [1/2] 正在删除已知缓存目录...
del /f /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\DXCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\D3DSCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\NVIDIA\DXCache\*" 2>nul
del /f /q "%USERPROFILE%\AppData\Local\AMD\DxCache\*" 2>nul

echo [2/2] 正在执行系统磁盘清理...
if exist "%SystemRoot%\System32\cleanmgr.exe" (
    echo 请使用弹出的磁盘清理窗口完成 -DirectX着色器缓存- 清理，完成清理后在本窗口按回车键继续...
    timeout /t 5 >nul
    start "" %SystemRoot%\System32\cleanmgr.exe
    pause >nul
) else (
    echo 警告: 未找到 cleanmgr.exe，跳过磁盘清理
)

echo 正在验证 CS2 游戏完整性...
start "" steam://validate/730
timeout /t 2 >nul
echo shader_build 730 | clip
echo.
echo.
echo.
echo "shader_build 730" 已复制到剪贴板!LF!!LF!===== 着色器重建操作指南 =====!LF!!LF![步骤1] 等待游戏验证完成!LF!1. 确保Steam已完成游戏完整性验证!LF!2. 打开Steam控制台（Steam顶部菜单 帮助 ^^^> 控制台）!LF!3. 按 Ctrl+V 粘贴命令后回车!LF!!LF![步骤2] 预加载游戏资源!LF!1. 创建本地房间或进入休闲模式!LF!2. 购买所有武器!LF!3. 投掷所有道具!LF!4. 执行所有动作!LF!5. 等待游戏完全流畅!LF!!LF![提示] 此过程只需执行一次!LF!============================!LF!

timeout /t 15
start "" steam://open/console
pause
exit