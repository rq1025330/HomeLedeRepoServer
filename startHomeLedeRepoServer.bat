@echo off
rem HomeLede Software Source Server v1.0
rem Powered by xiaoqingfeng
rem https://github.com/xiaoqingfengATGH/HomeLede
chcp 936

:checkPreCondition
set server_root=%~dp0

if not exist %server_root%conf\httpd.conf.template (
	echo ������ֻ����HomeLedeRepoServerĿ¼��ִ�У�
	goto quit
)
:startServer
echo.
echo HomeLede Software Server �����У���Ctrl+C�˳�..
%server_root%bin\httpd.exe
:quit
echo.
echo HomeLede Software Server��ֹͣ�����س��رմ��ڡ�
pause >nul