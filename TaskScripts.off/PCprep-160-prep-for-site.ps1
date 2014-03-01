# Purpose:
#	Get online, for validataion
# History:
#	2012-12-30	Phill.Rogers@2e2.je
# ToDo:
#	check if the app is already installed, at a sufficient version level
#	http://communities.quest.com/community/uwm/blog/2012/09/21/10-tips-for-a-cleaning-up-a-hard-drive

echo "Preparing for on-site delivery .. "
if($DeBug) { Write-Host " SoFar 10 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

Push-Location
cd "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
set-itemproperty . ProxyEnable 0
# set-itemproperty . ProxyServer "192.168.106.249:8080"
# set-itemproperty . ProxyOverride "<local>"
# new-itemproperty . AutoConfigURL
# set-itemproperty . AutoConfigURL <autoconfig url>
Pop-Location

Get-Date -Format s | %{$_ -replace 'T', ' '} >> "$outdir\times.log"
Write-Host "All done.  Press any key to close .."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
if($DeBug) { Write-Host " SoFar 24 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
