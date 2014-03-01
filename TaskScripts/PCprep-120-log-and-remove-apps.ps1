# Purpose:
#	Log pre-installed apps & remove unwanted ones.
# Sample file format for unwanted application patterns:
#	#TYPE Selected.System.Management.ManagementObject
#	Name
#	Java Auto Updater
#	Java 7 Update

echo "Logging pre-installed apps and removing unwanted .. "
if($DeBug) { Write-Host " SoFar 10 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

if (Test-Path $outdir\all-installed.csv) {
  echo "Log of pre-installed apps has already been gathered."
} else {
  $loia_o = Get-WmiObject -Class Win32_Product | Select-Object -Property IdentifyingNumber,Name,Vendor,Version
  $loia_o | Export-CSV $outdir\all-installed.csv -noType

  $loua_p = Import-CSV all-unwanted.csv | %{$_.Name}
  foreach ($unwanted_app_p in $loua_p ) {
    foreach ($installed_app_o in $loia_o) {
      if ($installed_app_o.Name -like "*$unwanted_app_p*") {
        $a_id = $installed_app_o.IdentifyingNumber
  #      echo "Found app=>$unwanted_app_p< with id=>$a_id< to be uninstalled."
        MSIexec /uninstall $a_id /passive
      }
    }
  }

}
if($DeBug) { Write-Host " SoFar 30 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
