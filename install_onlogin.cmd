@echo off

SET cf=%~dp0

net session >nul 2>&1
    if %errorLevel% == 0 (
        echo admin ok
    ) else (
        echo no admin
        timeout 3
        exit 1
    )
    
copy %cf%uniedge.cmd "C:\Program Files\Common Files"
schtasks /Create /TN uniedge /XML %cf%uniedge.xml

exit 0
