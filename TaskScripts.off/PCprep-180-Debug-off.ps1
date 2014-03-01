echo "Ending debug .. "

Stop-Transcript
Write-Host "Press any key to exit .. "
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
if($DeBug) { Write-Host " SoFar 6 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
