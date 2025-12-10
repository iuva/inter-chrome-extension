@echo off
chcp 65001 >nul
title 卸载RealVNC原生主机 - 浏览器扩展

echo.
echo ========================================
echo    RealVNC原生主机卸载脚本
echo ========================================
echo.

echo 正在检查系统环境...

:: 检查是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 错误：请以管理员权限运行此脚本！
    echo 右键点击脚本，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo ✅ 管理员权限验证通过

echo.
echo 正在卸载原生主机注册项...

:: 卸载Chrome注册项
echo 正在卸载Chrome注册项...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.realvnc.vncviewer" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Chrome注册项已删除
) else (
    echo ⚠️  Chrome注册项不存在或删除失败
)

:: 卸载Chromium注册项
echo 正在卸载Chromium注册项...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Chromium\NativeMessagingHosts\com.realvnc.vncviewer" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Chromium注册项已删除
) else (
    echo ⚠️  Chromium注册项不存在或删除失败
)

:: 卸载Microsoft Edge注册项
echo 正在卸载Microsoft Edge注册项...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.realvnc.vncviewer" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Microsoft Edge注册项已删除
) else (
    echo ⚠️  Microsoft Edge注册项不存在或删除失败
)

:: 卸载Firefox注册项
echo 正在卸载Firefox注册项...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\NativeMessagingHosts\com.realvnc.vncviewer" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Firefox注册项已删除
) else (
    echo ⚠️  Firefox注册项不存在或删除失败
)

echo.
echo ========================================
echo           卸载完成！
echo ========================================
echo.
echo ✅ 原生主机注册项已从以下浏览器移除：
echo    - Google Chrome
echo    - Microsoft Edge
echo    - Chromium
echo    - Firefox
echo.
echo 📝 注意：
echo    - 配置文件 com.realvnc.vncviewer.json 未被删除
echo    - Python脚本 realvnc_launcher.py 未被删除
echo    - 如需完全清理，请手动删除 native-host 目录
echo.

pause
exit /b 0