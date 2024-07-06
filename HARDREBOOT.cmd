@echo off
cd %~dp0
chcp 65001>nul
mode con:cols=75 lines=7
title "Check double run"
setlocal enabledelayedexpansion

set file=HARDREBOOT.log
set address1=8.8.8.8
set address2=google.com
set address3=ya.ru


:: Run once to setup script in to windows task sheduler (taskschd.msc)
schtasks /query /tn "HARDRESTART"
if %errorlevel% == 1 (
    echo Task not found. Adding task to the scheduler...
	:: or Provider[@Name='Netwtw06']
	:: or Provider[@Name='Netwtw04']
	:: or Provider[@Name='e1qexpress']
	:: or Provider[@Name='bcmwl63a']
	:: or Provider[@Name='RTL8168']
	:: or Provider[@Name='e1dexpress']
	:: or Provider[@Name='e1rexpress']
	:: or Provider[@Name='e1i68x64']
    schtasks /create /tn "HARDRESTART" /sc ONEVENT /ec System /mo "*[System[(Provider[@Name='e1i68x64'] or Provider[@Name='e1rexpress'] or Provider[@Name='Netwtw04'] or Provider[@Name='e1dexpress'] or Provider[@Name='RTL8168'] or Provider[@Name='bcmwl63a'] or Provider[@Name='e1qexpress'] or Provider[@Name='Netwtw06']) and (EventID=27)]]" /tr "C:\HARDREBOOT.cmd"
    echo exit
    timeout /t 5
    exit
)
set "WindowTitle=HARDRESTART Eth checker" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
	taskkill /PID %processpid%
)
title %WindowTitle%

schtasks /query /tn "HARDRESTART" | findstr /C:"Ready"
echo Ready errorlevel %errorlevel%
if %errorlevel% == 0 (
    echo Task is not running, run over tasksheduler
    schtasks /run /tn "HARDRESTART"
    exit
)

:checketh
cls
echo Check Ping %address1%
ping %address1% | find /i "TTL=" >nul
if errorlevel 1 (
    echo %address1% не отвечает
) else (
    echo %address1% ответил
    shutdown /a 2>nul
    goto exit
)

echo Check Ping %address2%
ping -n 5 %address2% >nul
if %errorlevel% equ 0 (
    echo %address2% respone
	shutdown /a 2>nul
    goto exit
)
echo Check Ping %address3%
ping -n 5 %address3% >nul
if %errorlevel% equ 0 (
    echo %address3% respone
	shutdown /a 2>nul
    goto exit
)

:reboot
echo No Connection
echo REBOOT?
shutdown /r /f /t 30
:secondmark
for /f %%x in ('powershell -command "Get-Date -format 'dd.MM.yyyy HH:mm:ss'"') do set datetime=%%x
set "text=%datetime% %TIME% Diconnect"
echo %text%
echo %text%>>%file%

echo  DISABLE REBOOT?

echo Second Check Ping %address2%
ping -n 5 %address2% >nul
if %errorlevel% equ 0 (
    echo %address2% respone
    set "text=!datetime! %TIME% !address2! respone"
    echo !text!
    echo !text!>>!file!
	shutdown /a
    goto exit
)
echo Second Check Ping %address3%
ping -n 5 %address3% >nul
if %errorlevel% equ 0 (
    echo %address3% respone
    set "text=!datetime! %TIME% !address3! respone"
    echo !text!
    echo !text!>>!file!
	shutdown /a
    goto exit
)

echo Second Check Ping %address1%
::ping -n 5 %address1% >nul
::if %errorlevel% equ 0 (
::    echo %address1% respone
::    set "text=!datetime! %TIME% !address1! respone"
::    echo !text!
::    echo !text!>>!file!
::	shutdown /a
::    goto exit
::)

goto secondmark

:exit
echo Eth connection established - exit
shutdown /a 2>nul
timeout /t 60
goto checketh
exit
