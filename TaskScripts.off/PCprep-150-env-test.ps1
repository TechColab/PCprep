echo "Testing vars .. `n"

echo "ObeyDir	-=>$OBeyDir<=-	The parent folder of these scripts."
echo "ObeyFileCMD	-=>$OBeyFileCMD<=-	The main CMD script."
echo "ObeyFilePS1	-=>$OBeyFilePS1<=-	The main PS1 script."
echo "winver	-=>$winver<=-	The version number of this Windows OS."
echo "spver	-=>$spver<=-	The version number of this Windows SP."
echo "arch	-=>$arch<=-	The architecture of this Windows OS (not the CPU)."
echo "outdir	-=>$outdir<=-	The output folder."
echo "USERNAME	-=>$env:USERNAME<=- "
echo "TEMP	-=>$env:TEMP<=- "
echo "pwd	-=>$pwd<=- "
Import-Module $ObeyDir\Modules\PSCX | Out-Null
if ( (Test-UserGroupMembership -GroupName Administrators) -eq $true ) {
  echo "I am a member of the Administrators group."
} else {
  echo "I am NOT a member of the Administrators group."
}

echo "`nPlease check the above variables."
Write-Host "Press any key to continue .. "
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
