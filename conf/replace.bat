@echo off
setlocal enabledelayedexpansion

set "file=%1"
set "file_personal=%2"
(
    for /f "tokens=*" %%i in (%file%) do (
        set s=%%i
        set s=!s:%3=%4!
        echo !s!
    )
)>%2