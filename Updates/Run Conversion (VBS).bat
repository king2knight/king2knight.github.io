@echo off
rem Runs ConvertDocToHtml.vbs (in the same folder as this .bat file) using
rem cscript, which prints output to this console window.

cscript //nologo "%~dp0ConvertDocToHtml.vbs"

echo.
pause
