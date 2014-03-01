
echo "Starting debug .. "

if($true) {
  $ErrorActionPreference="SilentlyContinue"
  Stop-Transcript | Out-Null
  $ErrorActionPreference = "Continue"
  Start-Transcript -Path $outdir\PCprep.log -Append
}
if($DeBug) { Write-Host " SoFar 10 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
