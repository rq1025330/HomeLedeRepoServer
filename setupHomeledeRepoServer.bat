@echo off
rem HomeLede Software Source Server v1.0
rem Powered by xiaoqingfeng
rem https://github.com/xiaoqingfengATGH/HomeLede
chcp 936

:checkPreCondition
set server_root=%~dp0
set SERVER_CONF_TEMPLATE=%server_root%conf\httpd.conf.template
set SERVER_CONF_TARGET=%server_root%conf\httpd.conf
set REPO_LINK_TEMPLATE=%server_root%conf\feedRepos.template
set REPO_LINK_TARGET=%server_root%feedRepos.conf
set SETUP_TEMP=%server_root%conf\_setup_ip_test.tmp

set conf_maker=%server_root%conf\replace.bat

if not exist %server_root%conf\httpd.conf.template (
	echo 本设置程序只能在HomeLedeRepoServer目录中执行！
	goto quit
)

Setlocal enabledelayedexpansion

:main
cls
ECHO ===================================================
ECHO.
ECHO            HomeLede软件源服务器设置
ECHO.
ECHO  https://github.com/xiaoqingfengATGH/HomeLede/wiki
ECHO.
ECHO ===================================================
ECHO 仅兼容IPv4。
ECHO 退出设置，请按Ctrl+C。
ECHO ===================================================
:inputIP
echo.
set host_ip=
set /p "host_ip=服务器IP （当前主机局域网IP）:"
if defined host_ip (
	echo %host_ip% | findstr /L "." > nul 2>nul
	if !errorlevel! equ 1 (
		echo.
		echo 输入IP非法，按回车重新输入。
		echo.
		pause >nul
		goto inputIP
	)
	del /q %SETUP_TEMP% >nul 2>nul
	netsh interface ipv4 show ipaddresses | findstr "%host_ip%" | find /v /c "" > %SETUP_TEMP%
	rem echo %SETUP_TEMP%
	set /p ip_exist=<%SETUP_TEMP%
	del /q %SETUP_TEMP% >nul 2>nul
	rem for /f "tokens=*" %%i in ('netsh interface ipv4 show ipaddresses ^| findstr "!host_ip!" ^| find /v /c ""') do (set ip_exist=%%i)
	rem echo "ip_exist=!ip_exist!"
	if "!ip_exist!"=="0" (
		echo.
		echo 您输入的IP似乎非本机IP，按回车重新输入。
		echo.
		pause >nul
		goto inputIP
	)
) else (
	echo 未输入服务器IP，按回车重新输入。
	echo.
	pause >nul
	goto inputIP
)
:inputPort
echo.
set host_port=
set /p host_port=服务器端口（有效范围1-65535）:
if defined host_port (
	echo %host_port% | findstr /R "[0-9]" >nul 2>nul
	if !errorlevel! equ 1 (
		echo 输入端口非法，按回车重新输入。
		echo.
		goto inputPort
	)
) else (
	echo 未输入服务器端口，按回车重新输入。
	echo.
	pause >nul
	goto inputPort
)
:confirmIP_Port
echo.
ECHO 即将把服务器IP及端口设置为：
ECHO %host_ip%:%host_port%
set confirm_ip_port=
set /p "confirm_ip_port=请确认以上输入正确（Y表示正确，N表示错误）:"
if defined confirm_ip_port (
	echo %confirm_ip_port% | findstr "y n Y N" >nul 2>nul
	if !errorlevel! equ 1 (
		echo 确认信息输入不正确，按回车重新输入。
		echo.
		goto confirmIP_Port
	)
	if "%confirm_ip_port%"=="N" goto main
	if "%confirm_ip_port%"=="n" goto main
) else (
	echo 未输入确认信息，按回车重新输入。
	echo.
	pause >nul
	goto confirmIP_Port
)

:createServerConf
echo.
echo 开始生成HomeLedeRepo服务器配置文件...

del /q %SERVER_CONF_TARGET% >nul 2>nul
del /q %SERVER_CONF_TARGET%.1 >nul 2>nul
del /q %SERVER_CONF_TARGET%.2 >nul 2>nul

call %conf_maker% %SERVER_CONF_TEMPLATE% %SERVER_CONF_TARGET%.1 ####SERVER_ROOT#### %server_root:~0,-1%

call %conf_maker% %SERVER_CONF_TARGET%.1 %SERVER_CONF_TARGET%.2 ####SERVER_IP#### %host_ip%

call %conf_maker% %SERVER_CONF_TARGET%.2 %SERVER_CONF_TARGET% ####SERVER_PORT#### %host_port%

echo.
echo 服务器配置文件生成完毕。

:createRepoLinks
echo.
echo 开始生成固件软件源配置...

del /q %REPO_LINK_TARGET% >nul 2>nul
del /q %REPO_LINK_TARGET%.1 >nul 2>nul

call %conf_maker% %REPO_LINK_TEMPLATE% %REPO_LINK_TARGET%.1 ####SERVER_IP#### %host_ip%

call %conf_maker% %REPO_LINK_TARGET%.1 %REPO_LINK_TARGET% ####SERVER_PORT#### %host_port%

echo.
echo 请将下面软件源配置粘贴进固件"系统"-"软件包"-"配置"页面中"发行版软件源"部分。
echo.
type %REPO_LINK_TARGET%
echo.
:quit
del /q %SERVER_CONF_TARGET%.1 >nul 2>nul
del /q %SERVER_CONF_TARGET%.2 >nul 2>nul
del /q %REPO_LINK_TARGET%.1 >nul 2>nul

echo.
echo 设置程序结束，按回车结束。
pause >nul