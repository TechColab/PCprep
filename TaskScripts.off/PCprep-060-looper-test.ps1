echo "Testing reboot loop .. "

if($DeBug) { Write-Host " SoFar 3 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
$a = new-object -comobject wscript.shell 
$intAnswer = $a.popup("Do you want to reboot?",0,"Reboot",4) 
If ($intAnswer -eq 6) { 
  bounce
} 
