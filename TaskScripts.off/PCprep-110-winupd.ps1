echo "Windows Updates .. "
if($DeBug) { Write-Host " SoFar 2 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

$ErrorActionPreference = 'SilentlyContinue'
$WUAo = (New-Object -com "Microsoft.Update.AgentInfo")
$WUAver = $WUAo.GetInfo("ProductVersionString")
if ( "$WUAver" -lt "7.0.6000.374" ) {
  echo "Updating Windows Update Agent .. "
  oscli "Resources\WindowsUpdateAgent30-$arch.exe" "/wuforce /quiet /norestart"
  Start-Sleep -Seconds 10
}
$ErrorActionPreference = 'Continue'
if($DeBug) { Write-Host " SoFar 13 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

Import-Module $ObeyDir\Modules\PSWindowsUpdate | Out-Null
if($DeBug) { Write-Host " SoFar 16 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

$mu = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$mu.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
# $mu.Services

# Get-WUInstall -IgnoreUserInput -AcceptAll -IgnoreReboot -Criteria "IsInstalled=0 and IsHidden=0" -Category "Critical Updates"
# Get-WUInstall -IgnoreUserInput -AcceptAll -IgnoreReboot -Criteria "IsInstalled=0 and IsHidden=0"
Get-WUInstall -AcceptAll -IgnoreReboot
if($DeBug) { Write-Host " SoFar 25 rc=$rc " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

echo "Checking if I need to reboot .. "
$rc = Get-WURebootStatus -Silent
if($DeBug) { Write-Host " SoFar 29 rc=$rc " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
if ($rc) { bounce }
