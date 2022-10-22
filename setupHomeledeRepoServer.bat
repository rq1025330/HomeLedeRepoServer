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
	echo �����ó���ֻ����HomeLedeRepoServerĿ¼��ִ�У�
	goto quit
)

Setlocal enabledelayedexpansion

:main
cls
ECHO ===================================================
ECHO.
ECHO            HomeLede���Դ����������
ECHO.
ECHO  https://github.com/xiaoqingfengATGH/HomeLede/wiki
ECHO.
ECHO ===================================================
ECHO ������IPv4��
ECHO �˳����ã��밴Ctrl+C��
ECHO ===================================================
:inputIP
echo.
set host_ip=
set /p "host_ip=������IP ����ǰ����������IP��:"
if defined host_ip (
	echo %host_ip% | findstr /L "." > nul 2>nul
	if !errorlevel! equ 1 (
		echo.
		echo ����IP�Ƿ������س��������롣
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
		echo �������IP�ƺ��Ǳ���IP�����س��������롣
		echo.
		pause >nul
		goto inputIP
	)
) else (
	echo δ���������IP�����س��������롣
	echo.
	pause >nul
	goto inputIP
)
:inputPort
echo.
set host_port=
set /p host_port=�������˿ڣ���Ч��Χ1-65535��:
if defined host_port (
	echo %host_port% | findstr /R "[0-9]" >nul 2>nul
	if !errorlevel! equ 1 (
		echo ����˿ڷǷ������س��������롣
		echo.
		goto inputPort
	)
) else (
	echo δ����������˿ڣ����س��������롣
	echo.
	pause >nul
	goto inputPort
)
:confirmIP_Port
echo.
ECHO �����ѷ�����IP���˿�����Ϊ��
ECHO %host_ip%:%host_port%
set confirm_ip_port=
set /p "confirm_ip_port=��ȷ������������ȷ��Y��ʾ��ȷ��N��ʾ����:"
if defined confirm_ip_port (
	echo %confirm_ip_port% | findstr "y n Y N" >nul 2>nul
	if !errorlevel! equ 1 (
		echo ȷ����Ϣ���벻��ȷ�����س��������롣
		echo.
		goto confirmIP_Port
	)
	if "%confirm_ip_port%"=="N" goto main
	if "%confirm_ip_port%"=="n" goto main
) else (
	echo δ����ȷ����Ϣ�����س��������롣
	echo.
	pause >nul
	goto confirmIP_Port
)

:createServerConf
echo.
echo ��ʼ����HomeLedeRepo�����������ļ�...

del /q %SERVER_CONF_TARGET% >nul 2>nul
del /q %SERVER_CONF_TARGET%.1 >nul 2>nul
del /q %SERVER_CONF_TARGET%.2 >nul 2>nul

call %conf_maker% %SERVER_CONF_TEMPLATE% %SERVER_CONF_TARGET%.1 ####SERVER_ROOT#### %server_root:~0,-1%

call %conf_maker% %SERVER_CONF_TARGET%.1 %SERVER_CONF_TARGET%.2 ####SERVER_IP#### %host_ip%

call %conf_maker% %SERVER_CONF_TARGET%.2 %SERVER_CONF_TARGET% ####SERVER_PORT#### %host_port%

echo.
echo �����������ļ�������ϡ�

:createRepoLinks
echo.
echo ��ʼ���ɹ̼����Դ����...

del /q %REPO_LINK_TARGET% >nul 2>nul
del /q %REPO_LINK_TARGET%.1 >nul 2>nul

call %conf_maker% %REPO_LINK_TEMPLATE% %REPO_LINK_TARGET%.1 ####SERVER_IP#### %host_ip%

call %conf_maker% %REPO_LINK_TARGET%.1 %REPO_LINK_TARGET% ####SERVER_PORT#### %host_port%

echo.
echo �뽫�������Դ����ճ�����̼�"ϵͳ"-"�����"-"����"ҳ����"���а����Դ"���֡�
echo.
type %REPO_LINK_TARGET%
echo.
:quit
del /q %SERVER_CONF_TARGET%.1 >nul 2>nul
del /q %SERVER_CONF_TARGET%.2 >nul 2>nul
del /q %REPO_LINK_TARGET%.1 >nul 2>nul

echo.
echo ���ó�����������س�������
pause >nul