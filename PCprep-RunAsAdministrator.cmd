@echo off
rem License:
rem PCprep-RunAsAdministrator.cmd - Prepare a PC for delivery.
rem Copyright (C) 2013-11-07 Phill W.J. Rogers
rem PhillRogers_at_JerseyMail.co.uk
rem
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <http://www.gnu.org/licenses/>.
rem
rem https://github.com/TechColab/PCprep.git
rem
rem Purpose:
rem	To prepare a freshly built PC to a fit state before deployment.
rem	This does not include the initial building, with imaging or scripting etc.
rem	This does not include the final deployment, with GroupPolicy, WSUS etc.
rem Usage:
rem	To launch this suite, please start with the following command script:
rem	PCprep-RunAsAdministrator.cmd
rem Notes:
rem	This CMD script first does all it needs to before handing over to PowerShell scripts.
rem	There are no user serviceable parts inside this script.
rem	All customisation should be done within the task specific scripts.
rem Legal:
rem	(c) 2013 Phill Rogers.    TechColab.co.je@gmail.com
rem
rem	See accompanying "PCprep.txt" file for revision history and other info.
rem	2013-03-03

set DEBUG=0
if "%1" EQU "SUB" if "%2" NEQ "" goto :SUB_%2

net SESSION >NUL: 2>&1
if not ERRORLEVEL 1 goto :ADMIN_OK
echo Launch me by right-click and RunAsAdministrator.
goto :ERR
:ADMIN_OK

rem if exist %PSModulePath%\..\PowerShel.exe goto :FAST_TRACK

set OBEYDIR=%~dp0
set OBEYDIR=%OBEYDIR:~0,-1%
rem excludes the trailing dir sep.
cd /D %OBEYDIR%
set OBEYFILECMD=%~nx0
echo I am running from %OBEYDIR% for this script.

if exist "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd" (
  del /Q/F "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd"
)

set WINVER=
for /F "usebackq tokens=3" %%i in (`reg QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion`) do set WINVER=%%i
if DEFINED WINVER goto :GOT_WIN
echo Failure to identify this Windows version.
goto :ERR
:GOT_WIN

set SPVER=0
reg QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CSDVersion 2>NUL: 1>&2
if ERRORLEVEL 1 goto :GOT_SP
for /F "usebackq tokens=5" %%i in (`reg QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CSDVersion`) do set SPVER=%%i
if DEFINED WINVER goto :GOT_SP
echo Failure to identify this ServicePack version.
goto :ERR
:GOT_SP

if "%WINVER%" GEQ "5.1" if "%WINVER%" LSS "6.2" goto :WIN_OK
echo Failure due to unexpected Windows version - I dont have installers for this.
goto :ERR
:WIN_OK
set ARCH=x86
if not "%PROCESSOR_ARCHITECTURE%" == "x86" set ARCH=x64
echo I have a version of Windows which I can work with.

setlocal EnableDelayedExpansion
rem If Office2010 installer is available then prompt for ProductKey and store for later use.
if not exist AppInstallers\OfficeHomeAndBusinessFPP-X17-75058.exe goto :SKIP_MSOLPK
if exist %windir%\Temp\PCprep-MSOLPK.txt goto :SKIP_MSOLPK
start "Microsoft Office Product Key" %COMSPEC% /c %0 SUB MSOLPK_INPUT
goto :MSOLPK_TIMEOUT
:SUB_MSOLPK_INPUT
echo Found Microsoft Office Home and Business Full Product Pack 2010 v14 installer.
echo Just hit enter now to skip it if you do not have a valid Product Key.
echo Otherwise please enter the key now, using hyphens/spaces if you like.
set /p MSOLPK="Product Key: "
if not _!MSOLPK!_ == __ echo !MSOLPK! > %windir%\Temp\PCprep-MSOLPK.txt
goto :EOF
:MSOLPK_TIMEOUT
set SECONDS=180
echo Waiting %SECONDS% seconds for input in other window.
echo You can still type after that but I may reboot without further notice.
:MSOLPK_LOOP
set /a SECONDS-=1
ping -n 2 localhost >NUL:
if !SECONDS! GEQ 0 (
  if not exist PCprep-MSOLPK.txt goto :MSOLPK_LOOP
) else (
  echo Timeout for input
  type NUL: > %windir%\Temp\PCprep-MSOLPK.txt
)
:SKIP_MSOLPK
setlocal DisableDelayedExpansion

if "%DEBUG%"=="1" echo SoFar 94 & pause
set OSCLI=NoServicePack
if "%WINVER%" NEQ "5.1" goto :SKIP_SP_51
  if "%SPVER%" GEQ "3" goto :SKIP_SP_51
  set SP=windowsxp-kb936929-sp3-x86-enu.exe
  if exist ServicePacks\%SP% goto :GOT_SP_51
    echo Couldnt find %OBEYDIR%\ServicePacks\%SP%
    echo Service Pack 3 for Windows XP is mandatory. I cannot continue.
    goto :ERR
:GOT_SP_51
  set OSCLI="ServicePacks\%SP% /passive /nobackup /forceappsclose /forcerestart"
:SKIP_SP_51
if "%DEBUG%"=="1" echo SoFar 106 & pause
if "%WINVER%" NEQ "5.2" goto :SKIP_SP_52
  if "%SPVER%" GEQ "2" goto :SP_OK
  if "%ARCH%" EQU "x64" set SP=WindowsServer2003.WindowsXP-KB914961-SP2-x64-ENU.exe
  if "%ARCH%" EQU "x86" set SP=WindowsServer2003-KB914961-SP2-x86-ENU.exe
  set OSCLI="ServicePacks\%SP% /unattend /forcerestart"
:SKIP_SP_52
if "%DEBUG%"=="1" echo SoFar 113 & pause
if "%WINVER%" NEQ "6.0" goto :SKIP_SP_60
  if "%SPVER%" GEQ "2" goto :SP_OK
  if "%SPVER%" EQU "1" set SP=Windows6.0-KB948465-%ARCH%.exe
  if "%SPVER%" EQU "0" set SP=Windows6.0-KB936330-%ARCH%-wave0.exe
  set OSCLI="ServicePacks\%SP% /unattend /forcerestart"
:SKIP_SP_60
if "%DEBUG%"=="1" echo SoFar 120 & pause
if "%WINVER%" NEQ "6.1" goto :SKIP_SP_61
  if "%SPVER%" GEQ "1" goto :SP_OK
  set SP=windows6.1-KB976932-%ARCH%.exe
  set OSCLI="ServicePacks\%SP% /unattend /forcerestart"
:SKIP_SP_61
if "%DEBUG%"=="1" echo SoFar 126 USERNAME -= %USERNAME% =- COMPUTERNAME -= %COMPUTERNAME% =- & pause

if "%USERNAME%" EQU "PCprep" goto :ACCT_OK
if "%USERNAME%" EQU "" goto :ACCT_OK
if "%USERNAME%" EQU "%COMPUTERNAME%$" goto :ACCT_OK
if "%DEBUG%"=="1" echo SoFar 131 & pause
  echo I need to switch user to a temporary admin account.
  net user | find "PCprep" >NUL:
  if ERRORLEVEL 1 (
    net user "PCprep" "password" /add /comment:"Temporary Administrator account for building PC." >NUL:
    net localgroup "Administrators" "PCprep" /add >NUL:
  )
  set HKP=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
  reg ADD "%HKP%" /v DefaultDomainName /d "%COMPUTERNAME%" /f >NUL:
  reg ADD "%HKP%" /v DefaultUserName /d "PCprep" /f >NUL:
  reg ADD "%HKP%" /v DefaultPassword /d "password" /f >NUL:
  reg ADD "%HKP%" /v AutoLogonCount /t REG_DWORD /d "999" /f >NUL:
  reg ADD "%HKP%" /v AutoAdminLogon /d "1" /f >NUL:
  set HKP=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion
  reg ADD "%HKP%\RunOnce" /v !PCprep /f /d "%OBEYDIR%\Modules\PsExec.exe /accepteula -s -i %OBEYDIR%\%OBEYFILECMD%" >NUL:
if "%DEBUG%"=="1" echo SoFar 146 & pause
  ping -n 6 -w 1000 127.0.0.1 >NUL:
  shutdown -r -t 00
  if ERRORLEVEL 1 goto :ERR
goto :EOF
:ACCT_OK

if "%DEBUG%"=="1" echo SoFar 153 & pause
if %OSCLI% == NoServicePack goto :SP_OK
if exist ServicePacks\%SP% goto :GOT_SP
  echo Couldnt find %OBEYDIR%\ServicePacks\%SP%
  echo I will continue anyway.
  goto :SP_OK
:GOT_SP
echo I have a Service Pack to install. This may take a while. Please be patient.
echo You can launch TaskManager with Alt+Ctl+Del to monitor as it runs.
echo After, I will then automatically reboot, logon and continue processing.
if "%DEBUG%"=="1" echo SoFar 163 & pause
rem echo @%OBEYDIR%\%OBEYFILECMD% > "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd"
echo @echo Waiting for background activity to settle. > "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd"
echo @ping -n 10 -w 1000 127.0.0.1 ^>NUL: >> "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd"
rem The following doesnt always seem to get the authority that it should. May need a delay.
echo @%OBEYDIR%\Modules\PsExec.exe /acceptelua -s -i %OBEYDIR%\%OBEYFILECMD% >> "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\PCprep.cmd"
%COMSPEC% /c %OSCLI%
if ERRORLEVEL 1 goto :ERR
goto :EOF
:SP_OK
echo I have a level of OS Service Pack which I can work with.

if "%DEBUG%"=="1" echo SoFar 175 & pause
set DN_INST=
reg QUERY "HKLM\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" >NUL: 2>&1
if not ERRORLEVEL 1 goto :DN_OK
if "%ARCH%" == "x86" set DN_INST=Resources\NetFx20SP2_x86.exe
if "%ARCH%" == "x64" set DN_INST=Resources\NetFx20SP2_x64.exe
if exist %DN_INST% goto :GOT_DN_INST
echo Failure to find %DN_INST% file in %OBEYDIR% folder.
goto :ERR
:GOT_DN_INST
echo Trying to install %DN_INST% ... 
%DN_INST% /passive
set DN_INST=
:DN_OK
echo I have a version of Dot-Net which I can work with.

set TMP=
set PS_INST=
reg QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine" >NUL: 2>&1
if ERRORLEVEL 1 goto :NEED_PS
for /F "usebackq tokens=3" %%i in (`reg QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine" /v PowerShellVersion`) do set TMP=%%i
if DEFINED TMP if "%TMP%" GEQ "2.0" goto :PS_OK
:NEED_PS
if "%WINVER%" EQU "5.1" if "%ARCH%" == "x86" set PS_INST=Resources\WindowsXP-KB968930-x86-ENG.exe
if "%WINVER%" EQU "5.2" if "%ARCH%" == "x86" set PS_INST=Resources\WindowsServer2003-KB968930-x86-ENG.exe
if "%WINVER%" EQU "5.2" if "%ARCH%" == "x64" set PS_INST=Resources\WindowsServer2003-KB968930-x64-ENG.exe
if "%WINVER%" EQU "6.0" if "%ARCH%" == "x86" set PS_INST=Resources\Windows6.0-KB968930-x86.msu
if "%WINVER%" EQU "6.0" if "%ARCH%" == "x64" set PS_INST=Resources\Windows6.0-KB968930-x64.msu
if exist %PS_INST% goto :GOT_PS_INST
echo Failure to find %PS_INST% file in %OBEYDIR% folder.
goto :ERR
:GOT_PS_INST
echo Trying to install %PS_INST% ... 
if "%WINVER%" EQU "6.0" (
  wusa.exe %PS_INST% /quiet /norestart
) else (
  %PS_INST% /passive /nobackup
)
rem /log:%OBEYDIR%\ps.log
set PS_INST=
set TMP=
:PS_OK
echo %PATHEXT% | find /C ";.PS1" >NUL: || set PATHEXT=%PATHEXT%;.PS1
echo %PSModulePath% | find /C "Modules" >NUL: || set PSModulePath=%SystemRoot%\system32\WindowsPowerShell\v1.0\Modules\
echo %PATH% | find /C "PowerShell" >NUL: || set Path=%Path%;%SystemRoot%\System32\WindowsPowerShell\v1.0\;
echo I have a version of PowerShell which I can work with.

if exist TaskScripts\PCprep-???-*.ps1 goto :SCRIPTS_OK
echo Failure to find any PowerShell scripts to be run.
echo Will continue to the clean-up routine.
rem goto :ERR
:SCRIPTS_OK
echo I have all I need to process %COMPUTERNAME% ... 

:FAST_TRACK
if "%DEBUG%"=="1" echo SoFar 230 & pause
PowerShell -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File PCprep.ps1

if ERRORLEVEL 1 pause
goto :EOF
:ERR
pause
:EOF
