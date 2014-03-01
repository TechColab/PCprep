echo "Optimising system for the rest of the install .. "

if($DeBug) { Write-Host " SoFar 3 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
Disable-ComputerRestore -Drive $env:windir.SubString(0,3)
if($DeBug) { Write-Host " SoFar 5 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

if ( $(Get-ExecutionPolicy) -match "(^Restricted)|(AllSigned)|(RemoteSigned)" ) {
  Write-Output "Setting Execution Policy .. "
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
if($DeBug) { Write-Host " SoFar 10 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
}

#if($DeBug) { Write-Host " SoFar 13 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  $hkp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures"
#  $hkp = $hkp + "\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24"
#  if ( -not (Test-Path -PathType Container $hkp) ) {
#if($DeBug) { Write-Host " SoFar 17 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#    mkdir $hkp -Force | Out-Null
#if($DeBug) { Write-Host " SoFar 19 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#  }
#  New-ItemProperty -Path $hkp -Name "Category" -Value 1 -PropertyType "Dword" -Force | Out-Null
#if($DeBug) { Write-Host " SoFar 22 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
#
# Add-Type –Path .\Interop.NETWORKLIST.dll
# $nlm = new-object NETWORKLIST.NetworkListManagerClass
# $nlm.GetNetworks("NLM_ENUM_NETWORK_ALL") | select @{n="Name";e={$_.GetName()}},@{n="Category";e={$_.GetCategory()}},IsConnected,IsConnectedToInternet
# $net = $nlm.GetNetworks("NLM_ENUM_NETWORK_CONNECTED") | select -first 1
# $net.SetCategory(1)
#
# $nlm.GetNetworkConnections() | select @{n="Connectivity";e={$_.GetConnectivity()}}, @{n="DomainType";e={$_.GetDomainType()}}, @{n="Network";e={$_.GetNetwork().GetName()}}, IsConnectedToInternet,IsConnected

if($DeBug) { Write-Host " SoFar 32 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  $nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B'))
if($DeBug) { Write-Host " SoFar 34 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  $net = $nlm.GetNetworks(1) | select -first 1
if($DeBug) { Write-Host " SoFar 36 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  $net.SetCategory(1)
if($DeBug) { Write-Host " SoFar 38 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
  Enable-PSRemoting -Force | Out-Null
if($DeBug) { Write-Host " SoFar 40 USERNAME -= $env:USERNAME =- COMPUTERNAME -= $env:COMPUTERNAME =- " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
