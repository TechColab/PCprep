# Purpose:
#	Add Microsoft apps & middle-ware
# Notes:
#	IE9 & IE10 are both big enough to make offline install desireable, but 
#	have pre-requisites which are only available online so cannot use the "/update-no" options.
#	May be able to install MSE here as it requires prior WGA which cannot be automated.
# ToDo:
#

echo "Installing offline apps with online assist .. "
if($DeBug) { Write-Host " SoFar 11 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

# IE
if ($true) { # Do you want IE9 ?
  if ( $winver -eq "6.1" -and $spver -ge "1" ) { # W7
    if ( $arch -eq "x64" ) {
      $prog = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
      if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("9.0")) ) {
        echo "Already installed: IE 9.0 - 32-bit"
      } else {
        sudo "queued" $DefaultUserName "ObeyFilePS1"
        oscli "Resources\IE9-Windows7-x86-enu.exe" "/passive /forcerestart /log:$outdir"
      }
    }
    $prog = "C:\Program Files\Internet Explorer\iexplore.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("9.0")) ) {
      echo "Already installed: IE 9.0"
    } else {
      sudo "queued" $DefaultUserName "ObeyFilePS1"
      oscli "Resources\IE9-Windows7-$arch-enu.exe" "/passive /forcerestart /log:$outdir"
    }
  }
}
if ($true) { # Do you want IE10 ?
  if ( $winver -eq "6.1" -and $spver -ge "1" ) { # W7
    if ( $arch -eq "x64" ) {
      $prog = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
      if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("10.0")) ) {
	echo "Already installed: IE 10.0 - 32-bit"
      } else {
	sudo "queued" $DefaultUserName "ObeyFilePS1"
	oscli "Resources\IE10-Windows6.1-x86-en-us.exe" "/passive /forcerestart /log:$outdir"
      }
    }
    $prog = "C:\Program Files\Internet Explorer\iexplore.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("10.0")) ) {
      echo "Already installed: IE 10.0"
    } else {
      sudo "queued" $DefaultUserName "ObeyFilePS1"
      oscli "Resources\IE10-Windows6.1-$arch-en-us.exe" "/passive /forcerestart /log:$outdir"
    }
  }
}
if ( $winver -eq "6.0" -and $spver -ge "2" ) { # Vista
  if ( $arch -eq "x64" ) {
    $prog = "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("9.0")) ) {
      echo "Already installed: IE 9.0 - 32-bit"
    } else {
      sudo "queued" $DefaultUserName "ObeyFilePS1"
      oscli "Resources\IE9-WindowsVista-x86-enu.exe" "/passive /forcerestart /log:$outdir"
    }
  }
  $prog = "C:\Program Files\Internet Explorer\iexplore.exe"
  if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("9.0")) ) {
    echo "Already installed: IE 9.0"
  } else {
    sudo "queued" $DefaultUserName "ObeyFilePS1"
    oscli "Resources\IE9-WindowsVista-$arch-enu.exe" "/passive /forcerestart /log:$outdir"
  }
}

# Write-Host "Press any key to continue .. MSE "
# $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

# MSE
if ( $false ) {
  oscli "Resources\mseinstall_x86.exe" "" # requires prior WGA validation
  oscli "Resources\mpam-fe_x86.exe" ""
  oscli "Resources\nis_full_x86.exe" ""
}
if($DeBug) { Write-Host " SoFar 82 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
