# Purpose:
#	Log some generally useful info.
# History:
#	2012-12-30	Phill.Rogers@2e2.je
#

echo "Gathering info .. "
if($DeBug) { Write-Host " SoFar 8 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
$lf = "$outdir\gen_info.txt"

if(Test-Path $lf) {
  echo "Info has already been logged."
} else {

  # GetTodaysDate
  Get-Date -Format s | %{$_ -replace 'T', ' '} >> $lf

  $original_computer_name = $env:COMPUTERNAME
  $original_computer_name  >> $lf

  # List installed snapins
  Get-PSSnapin -Registered >> $lf

  # Get CPU info
  Get-WmiObject -class Win32_Processor >> $lf

  # Check disk space on local disks on local server
  Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" >> $lf

  # Checking what services are running on a computer.
  Get-WmiObject Win32_Service | Select-Object Name >> $lf

  # GetMAC
  $lo_nic_o = Get-WmiObject win32_networkadapter
  $prime_nic_o = ($lo_nic_o | ?{$_.AdapterType -eq "Ethernet 802.3"} | Sort-Object -Property Index)
  if($prime_nic_o.Count -ge 2) { $prime_nic_o = $prime_nic_o[0] }
  $mac = $prime_nic_o | %{$_.macaddress}
  echo "Print NIC MAC address = $mac" >> $lf

  # DxDiag
  # oscli "$env:SystemRoot\System32\dxdiag.exe" "/whql:off /x dxdiag.xml"
  # oscli "$env:SystemRoot\System32\dxdiag.exe" "/whql:off /t dxdiag.txt"
  # find /C ": No problems found." dxdiag.txt # $3 should be 6
}
if($DeBug) { Write-Host " SoFar 45 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
