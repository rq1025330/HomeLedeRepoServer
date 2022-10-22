@echo off
rem HomeLede Software Source Server v1.0
rem Powered by xiaoqingfeng
rem https://github.com/xiaoqingfengATGH/HomeLede
chcp 936

:checkPreCondition
set server_root=%~dp0

if not exist %server_root%conf\httpd.conf.template (
	echo 本程序只能在HomeLedeRepoServer目录中执行！
	goto quit
)
:startServer
echo.
echo HomeLede Software Server 运行中，按Ctrl+C退出..
%server_root%bin\httpd.exe
:quit
echo.
echo HomeLede Software Server已停止，按回车关闭窗口。
pause >nul