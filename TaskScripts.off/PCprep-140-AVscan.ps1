if ( Test-Path -PathType Leaf $ObeyDir.Substring(0,2)\PortableApps\ClamWinPortable\cwp-cli.cmd ) {
if($DeBug) { Write-Host " SoFar 2 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  oscli $ObeyDir.Substring(0,2)\PortableApps\ClamWinPortable\cwp-cli.cmd
}
if($DeBug) { Write-Host " SoFar 5 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
