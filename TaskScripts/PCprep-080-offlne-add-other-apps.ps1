echo "Installing offline apps .. "

if($DeBug) { Write-Host " SoFar 3 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
# Java
if ( $false ) {
  if ( $arch -eq "x86" ) {
    $prog = "$env:SystemRoot\system32\java.exe"
    if ( (Test-Path $prog) -and ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($prog).Fileversion.StartsWith("7.0")) ) {
      echo "Already installed: Java 7.0"
    } else {
      oscli "AppInstallers\jre-7u10-windows-i586.exe" $null
    }
  }
}

# PDFCreator
# Adobe Acrobat Reader
if($DeBug) { Write-Host " SoFar 18 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
