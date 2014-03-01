# License:
# PCprep.ps1 - Prepare a PC for delivery.
# Copyright (C) 2013-11-07 Phill W.J. Rogers
# PhillRogers_at_JerseyMail.co.uk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# https://github.com/TechColab/PCprep.git
#
# Purpose:
#	To prepare a freshly built PC to a fit state before deployment.
#	This does not include the initial building, with imaging or scripting etc.
#	This does not include the final deployment, with GroupPolicy, WSUS etc.
# Usage:
#	To launch this suite, please start with the following command script:
#	PCprep-RunAsAdministrator.cmd
# Notes:
#	This PS1 script manages the PC on behalf of the various Task Scripts.
#	There are no user serviceable parts inside this script.
#	All customisation should be done within the task specific scripts.
# Legal:
#	(c) 2013 Phill Rogers.    TechColab.co.je@gmail.com
#
#	See accompanying "PCprep.txt" file for revision history and other info.
#	2013-03-03

param( [string]$arg1="" )
$DeBug = $false

Write-Output "Initialising environment for TaskScripts .. "

if (Test-Path -PathType Leaf "$env:ALLUSERSPROFILE\Start Menu\Programs\Startup\PCprep.cmd" ) {
  Remove-Item "$env:ALLUSERSPROFILE\Start Menu\Programs\Startup\PCprep.cmd" -Force
}

$ObeyDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$ObeyFilePS1 = Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf
# $ObeyDir="C:\PCprep" ; $ObeyFilePS1="PCprep.ps1" ; cd $ObeyDir
$DefaultUserName = "PCprep" ; $DefaultPassword = "password"
Set-Location $ObeyDir
$winver = (Get-WMIObject Win32_OperatingSystem).Version.SubString(0,3)
if ( $env:PROCESSOR_ARCHITECTURE -eq "x86" ) {
  $arch = "x86"
} else {
  $arch = "x64"
} # ignoring Itanium and ARM for now. NB PowerShell doesn't know during LocalService !

$spver = (Get-WMIObject Win32_OperatingSystem).ServicePackMajorVersion
$global_rc = 1 # EXIT_FAILURE

function oscli ([string]$prog, [string]$parm) {
  $global_rc = 1 # EXIT_FAILURE
  if ( Test-Path -PathType Leaf $prog ) {
    Write-Output "Running $prog .. "
    if ($parm -ne $null -and $parm -ne "") {
      $proc = Start-Process -FilePath "$ObeyDir\$prog" -ArgumentList $parm -Wait -PassThru
    } else {
      $proc = Start-Process -FilePath "$ObeyDir\$prog" -Wait -PassThru
    }
    if ($proc.ExitCode -ne 0) {
      Write-Output "FYI: Running of $prog returned error code: $($proc.ExitCode)"
    } else {
      $global_rc = 0 # EXIT_SUCCESS
    }
  } else {
    Write-Output "Could not find the executable specified: $prog "
  } 
  return # PowerShell doesnt do function return codes like other languages!
}

function sudo ([string]$when="", [string]$who="", [string]$what="") {
if($DeBug) { Write-Host " SoFar 63 $what " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  Push-Location
  Set-Location "HKLM:\Software\Microsoft\Windows NT\Currentversion\WinLogon"
  Set-ItemProperty -Path $pwd.Path -Name "DefaultDomainName" -Value $env:COMPUTERNAME -Force | Out-Null
  if ( $who -eq "" -or $who -eq $null ) { $who = "Administrator" }
  Set-ItemProperty -Path $pwd.Path -Name "DefaultUserName" -Value $who -Force | Out-Null
  if ( $who -eq "Administrator" ) {
    Set-ItemProperty -Path $pwd.Path -Name "AutoAdminLogon" -Value 0 -Force | Out-Null
    Set-ItemProperty -Path $pwd.Path -Name "AutoLogonCount" -Value 0 -Force | Out-Null
    Set-ItemProperty -Path $pwd.Path -Name "DefaultPassword" -Value "NotTheRealPassword" -Force | Out-Null
  } else {
    Set-ItemProperty -Path $pwd.Path -Name "AutoAdminLogon" -Value 1 -Force | Out-Null
    Set-ItemProperty -Path $pwd.Path -Name "AutoLogonCount" -Value 999 -Force | Out-Null
    Set-ItemProperty -Path $pwd.Path -Name "DefaultPassword" -Value $DefaultPassword -Force | Out-Null
  }
  Set-Location "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
  if ( $what -eq "ObeyFileCMD" ) {
    $what = "$ObeyDir\$ObeyFileCMD"
  }
  if ( $what -eq "ObeyFilePS1" ) {
    $oscli = "$env:SystemRoot\system32\WindowsPowerShell\v1.0\PowerShell.exe "
    $oscli += "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File $ObeyDir\$ObeyFilePS1"
    $what = $oscli
  }
if($DeBug) { Write-Host " SoFar 87 $what " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  if ( $what -ne "" -and $what -ne $null ) {
    $what = "$ObeyDir\Modules\PsExec.exe /accepteula -s -i " + $what
    New-ItemProperty -Path $pwd.Path -Name "!PCprep" -Value "$what" -PropertyType "String" -Force | Out-Null
@"
@echo off
echo Waiting for background activity to settle.
ping -n 10 -w 1000 127.0.0.1 > NUL:
$what
"@ | Out-File -FilePath "$env:ALLUSERSPROFILE\Start Menu\Programs\Startup\PCprep.cmd" -Encoding ASCII -Force
  } else {
    Remove-ItemProperty -Path $pwd.Path -Name "!PCprep" -Force -ErrorAction SilentlyContinue | Out-Null
    if (Test-Path -PathType Leaf "$env:ALLUSERSPROFILE\Start Menu\Programs\Startup\PCprep.cmd" ) {
      Remove-Item "$env:ALLUSERSPROFILE\Start Menu\Programs\Startup\PCprep.cmd" -Force
    }
  }
  Pop-Location
  if ( $when -eq "reboot" -or $when -eq "logoff" ) {
if($DeBug) { Write-Host " SoFar 105 When [$when] .. " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
    Start-Sleep -Seconds 3
  }
  if ( $when -eq "reboot" ) {
    Restart-Computer -Force
    While ($true) { Start-Sleep -Seconds 1 } # prevents async return
  }
  if ( $when -eq "logoff" ) {
    (Get-WMIObject Win32_OperatingSystem).Win32Shutdown(0) | Out-Null # does a logoff
    While ($true) { Start-Sleep -Seconds 1 } # prevents async return
  }
}

function bounce () {
  sudo "reboot" $DefaultUserName "ObeyFilePS1"
}

function logit ([string]$message="") {
  if ($outdir) {
    $timestamp = Get-Date -Format s | %{$_ -replace 'T', ' '}
    Write-Output "$timestamp`t$message" >> "$outdir\PCprep-$env:COMPUTERNAME.log"
  }
}

function uq ([string]$text) {
  if ( $text.StartsWith('"') -and $text.EndsWith('"') ) {
    $text = $text.Substring(1,$text.Length -2)
  }
  $text
}
$ObeyFileCMD = uq $env:OBEYFILECMD
if ( $ObeyFileCMD -eq "" -or $ObeyFileCMD -eq $null ) {
  $ObeyFileCMD = "PCprep-RunAsAdministrator.cmd"
}

# Load these on demand within the TaskScript as they are slow to initialize
# Import-Module $ObeyDir\Modules\PSWindowsUpdate | Out-Null
# Import-Module $ObeyDir\Modules\PSCX | Out-Null

if ( $arg1 -ne "CleanUp" ) {

if($DeBug) { Write-Host " SoFar 146 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

  if ( $env:USERNAME -ne $DefaultUserName -and $env:USERNAME -ne $null -and $env:USERNAME -ne "" -and $env:USERNAME -ne ($env:COMPUTERNAME + "$") ) {
if($DeBug) { Write-Host " SoFar 149 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
    $computer = [ADSI]"WinNT://$env:COMPUTERNAME,Computer"
    $colUsers = ($computer.psbase.children | ?{$_.psBase.schemaClassName -eq "User"} | Select-Object -expand Name)
    if ( -not $colUsers -contains $DefaultUserName ) {
      Write-Output "Creating temporary account .. "
if($DeBug) { Write-Host " SoFar 154 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
      $ErrorActionPreference = 'SilentlyContinue'
      $user = $computer.Create("User", $DefaultUserName)
      $user.SetPassword($DefaultPassword)
      $user.SetInfo()
      $user.Put("Description", "Temporary Administrator account for building PC.")
      $user.SetInfo()
      $group=[ADSI]"WinNT://$env:COMPUTERNAME/Administrators,Group"
      $group.Add($user.Path)
      $group.SetInfo()
      $ErrorActionPreference = 'Continue'
    }
if($DeBug) { Write-Host " SoFar 166 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
    Write-Output "Switching user to temporary account .. "
    sudo "reboot" $DefaultUserName "ObeyFilePS1" # reboot more reliable than logging off
  }
if($DeBug) { Write-Host " SoFar 170 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

  Write-Output "Searching for writable folder .. "
  $ErrorActionPreference = 'SilentlyContinue'
  if ( $outdir -eq "" -or $outdir -eq $null ) {
    if ( (Test-Path -PathType Container $env:windir\TEMP ) -eq $true ) {
      mkdir $env:windir\TEMP\PCprep.pc | out-null
      if ( Test-Path -PathType Container $env:windir\TEMP\PCprep.pc ) {
	Write-Output "write-test" > $env:windir\TEMP\PCprep.pc\write-test.tmp
	if ( $? -eq $true) {
	  Remove-Item -Force $env:windir\TEMP\PCprep.pc\write-test.tmp
	  $outdir = "$env:windir\TEMP\PCprep.pc"
	} else {
	  Remove-Item -Force $env:windir\TEMP\PCprep.pc
	}
      }
    }
  }
if($DeBug) { Write-Host " SoFar 188 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  if ( $outdir -eq "" -or $outdir -eq $null ) {
    if ( (Test-Path -PathType Container $ObeyDir\Logs\$env:COMPUTERNAME.pc) -eq $false ) {
      mkdir $ObeyDir\Logs\$env:COMPUTERNAME.pc | out-null
    }
    if ( Test-Path -PathType Container $ObeyDir\Logs\$env:COMPUTERNAME.pc ) {
      Write-Output "write-test" > $ObeyDir\Logs\$env:COMPUTERNAME.pc\write-test.tmp
      if ( $? -eq $true) {
	Remove-Item -Force $ObeyDir\Logs\$env:COMPUTERNAME.pc\write-test.tmp
	$outdir = "$ObeyDir\Logs\$env:COMPUTERNAME.pc"
      } else {
	Remove-Item -Force $ObeyDir\Logs\$env:COMPUTERNAME.pc | out-null
      }
    }
  }
if($DeBug) { Write-Host " SoFar 203 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  # consider searching for USB flash memory device ?
  if ( $outdir -eq "" -or $outdir -eq $null ) {
    if ( (Test-Path -PathType Container $env:TEMP\$env:COMPUTERNAME.pc) -eq $false ) {
      mkdir $env:TEMP\$env:COMPUTERNAME.pc | out-null
    }
    if ( Test-Path -PathType Container $env:TEMP\$env:COMPUTERNAME.pc ) {
      Write-Output "write-test" > $env:TEMP\$env:COMPUTERNAME.pc\write-test.tmp
      if ( $? -eq $true ) {
	Remove-Item -Force $env:TEMP\$env:COMPUTERNAME.pc\write-test.tmp
	$outdir = "$env:TEMP\$env:COMPUTERNAME.pc"
      }
    }
  }
  if ( $outdir -eq "" -or $outdir -eq $null ) {
    Write-Output "Cannot find a writable folder. Will continue anyway."
  } else {
    Write-Output "Writing output to $outdir folder."
  }
if($DeBug) { Write-Host " SoFar 222 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  $ErrorActionPreference = 'Continue' # Continue SilentlyContinue Stop Inquire

#  if ( $(Get-ExecutionPolicy) -match "(^Restricted)|(AllSigned)|(RemoteSigned)" ) {
#    Write-Output "Setting Execution Policy .. "
#    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
#if($DeBug) { Write-Host " SoFar 228 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  }
#if($DeBug) { Write-Host " SoFar 230 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  $hkp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures"
#  $hkp = $hkp + "\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24"
#  if ( -not (Test-Path -PathType Container $hkp) ) {
#if($DeBug) { Write-Host " SoFar 234 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#    mkdir $hkp -Force | Out-Null
#if($DeBug) { Write-Host " SoFar 236 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  }
#  New-ItemProperty -Path $hkp -Name "Category" -Value 1 -PropertyType "Dword" -Force | Out-Null
#if($DeBug) { Write-Host " SoFar 239 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#
# Add-Type –Path .\Interop.NETWORKLIST.dll
# $nlm = new-object NETWORKLIST.NetworkListManagerClass
# $nlm.GetNetworks("NLM_ENUM_NETWORK_ALL") | select @{n="Name";e={$_.GetName()}},@{n="Category";e={$_.GetCategory()}},IsConnected,IsConnectedToInternet
# $net = $nlm.GetNetworks("NLM_ENUM_NETWORK_CONNECTED") | select -first 1
# $net.SetCategory(1)
#
# $nlm.GetNetworkConnections() | select @{n="Connectivity";e={$_.GetConnectivity()}}, @{n="DomainType";e={$_.GetDomainType()}}, @{n="Network";e={$_.GetNetwork().GetName()}}, IsConnectedToInternet,IsConnected
#
#if($DeBug) { Write-Host " SoFar 249 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  $nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))
#if($DeBug) { Write-Host " SoFar 251 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  $net = $nlm.GetNetworks(1) | select -first 1
#if($DeBug) { Write-Host " SoFar 253 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  $net.SetCategory(1)
#if($DeBug) { Write-Host " SoFar 255 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  Enable-PSRemoting -Force | Out-Null
#if($DeBug) { Write-Host " SoFar 257 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

  # Environment is now ready for task scripts.
  logit "Starting each task script .. "
  Write-Output "Starting each task script .. "

  Get-ChildItem TaskScripts\PCprep-[0-9][0-9][0-9]-*.ps1 | Sort-Object Name | ForEach-Object{& $_}

  Write-Output "Finished each task script .. "
  logit "Finished each task script."

  Write-Output "Preparing to delete temporary account .. "
  Write-Output "`nPlease logon with a normal Administrator account when prompted.`n"
  $ErrorActionPreference = 'SilentlyContinue'
  $user=[ADSI]"WinNT://$env:COMPUTERNAME/$DefaultUserName,User"
  $group=[ADSI]"WinNT://$env:COMPUTERNAME/Users,Group"
  $group.Add($user.Path)
  $group.SetInfo()
  Write-Output "Demoting temporary account .. "
  $group=[ADSI]"WinNT://$env:COMPUTERNAME/Administrators,Group"
  $group.Remove($user.Path)
  $group.SetInfo()
  $ErrorActionPreference = 'Continue'
if($DeBug) { Write-Host " SoFar 280 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

  $oscli = "$env:SystemRoot\system32\WindowsPowerShell\v1.0\PowerShell.exe "
  $oscli += "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -File $ObeyDir\$ObeyFilePS1 -arg1 CleanUp"
  Write-Output "Switching user from temporary account .. "
  sudo "reboot" "Administrator" $oscli

} else {
  # $a = new-object -comobject wscript.shell 
  # $intAnswer = $a.popup("Do you want to delete the temporary account?",0,"Delete",4) 
  # If ($intAnswer -eq 6) { 

  if ( $winver -ge "6.0" ) {
    Write-Host "Removing temporary account profile (W7) .. "
    & $ObeyDir\Modules\Remove-UserProfile.ps1 $env:COMPUTERNAME $DefaultUserName
  } else {
    Write-Host "Removing temporary account profile (XP) .. "
    $sid = ((New-Object System.Security.Principal.NTAccount($DefaultUserName)).Translate([System.Security.Principal.SecurityIdentifier])).Value
    if ( $sid -ne "" -and $sid -ne $null ) {
      $hkp = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
      $pp = (Get-ChildItem $hkp | ?{$_.Name -match $sid } | %{Get-ItemProperty $_.pspath}).ProfileImagePath
      if ( $pp -ne "" -and $pp -ne $null ) {
	if ( Test-Path $pp ) {
	  # Get-ChildItem -Recurse -Force $pp | Remove-Item -Force -Recurse
	  Remove-Item -Force -Recurse $pp
	}
      }
      Push-Location
      Set-Location $hkp
      if ( Test-Path $sid ) {
	Remove-Item -Force -Recurse $sid
      }
      Pop-Location
    }

  }
  Write-Host "Removing temporary account .. "
  ([ADSI]"WinNT://$env:COMPUTERNAME,Computer").psbase.invoke("Delete","User",$DefaultUserName)

  # }

  logit "All done."
  Write-Host "All done."
  Start-Sleep -Seconds 4
}
