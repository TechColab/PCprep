# Purpose:
#	Add Microsoft apps & middle-ware
# History:
#	check if the app is already installed, at a sufficient version level
#	reorganise for app-arch-winver grouping. IE after WMP
#	re-boot after IE not required as we don't actually use IE and we will reboot later.
#	only bounce after successful Sp install.  Allways tolerate missing installer
# Notes:
#	Some apps only supported after certain SP - hence instaltion order is important.
#	Some apps can have both 32 & 64 bit version installed on a 64-bit OS.
#	The "Program Files" folder contains 64-bit apps on a 64-bit OS.
#	The "Program Files (x86)" folder contains 32-bit apps on a 64-bit OS.
#	Cannot find munch info on latest WMP for each OS.
#	Cannot install MSE as it requires prior WGA which cannot be automated.
# ToDo:
#

echo "Installing offline apps .. "

if($DeBug) { Write-Host " SoFar 20 winver=$winver spver=$spver arch=$arch " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

# IE
if ( $winver -eq "5.1" ) { # XP, 32-bit
  if ( $arch -eq "x86" ) {
    $prog = "C:\Program Files\Internet Explorer\iexplore.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("8.0")) ) {
      echo "Already installed: IE 8.0"
    } else {
      # sudo "queued" $DefaultUserName "ObeyFilePS1"
      oscli "Resources\IE8-WindowsXP-x86-ENU.exe" "/passive /update-no /no-default /norestart /log:$outdir"
    }
  }
}
if ( $winver -eq "5.2" ) { # XP 64-bit, Server 2003, inc R2
  if ( $arch -eq "x64" ) {
    $prog = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("8.0")) ) {
      echo "Already installed: IE 8.0 - 32-bit"
    } else {
      # sudo "queued" $DefaultUserName "ObeyFilePS1"
      oscli "Resources\IE8-WindowsXP-$arch-ENU.exe" "/passive /update-no /no-default /norestart /log:$outdir" # TBC
    }
  }
  $prog = "C:\Program Files\Internet Explorer\iexplore.exe"
  if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("8.0")) ) {
    echo "Already installed: IE 8.0"
  } else {
    # sudo "queued" $DefaultUserName "ObeyFilePS1"
    oscli "Resources\IE8-WindowsXP-x86-ENU.exe" "/passive /update-no /no-default /norestart /log:$outdir" # TBC
  }
}

if($DeBug) { Write-Host " SoFar 53 winver=$winver spver=$spver arch=$arch " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

# WMP
if ( $winver -eq "5.1" ) { # XP
  if ( $arch -eq "x86" ) {
    $prog = "C:\Program Files\Windows Media Player\wmplayer.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("11.0")) ) {
      echo "Already installed: WMP 11.0"
    } else {
      oscli "Resources\wmp11-windowsxp-x86-enu.exe" "/Q"
    }
  }
}

if($DeBug) { Write-Host " SoFar 67 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
