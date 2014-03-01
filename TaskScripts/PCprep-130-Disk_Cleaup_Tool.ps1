if ( -not Test-Path -PathType Leaf "$OutDir/defrag.log" ) {
if($DeBug) { Write-Host " SoFar 2 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }

  $ErrorActionPreference = 'SilentlyContinue'

  Write-Output "User TEMP and TMP .. "
  Get-ChildItem $env:TEMP -Force | %{Remove-Item $env:TEMP\$_ -Recurse -Confirm:$false -Force }
  Remove-Item -Recurse "$env:TEMP\*" -Force
  Get-ChildItem $env:TMP -Force | %{Remove-Item $env:TMP\$_ -Recurse -Confirm:$false -Force }
  Remove-Item -Recurse "$env:TMP\*" -Force

  Write-Output "Recycle Bin .. "
  $objShell = New-Object -ComObject Shell.Application
  $objFolder = $objShell.Namespace(0xA)
  $objFolder.Items() | %{ Remove-Item $_.Path -Recurse -Confirm:$false -Force}

  Write-Output "Windows Update roll-backs .. "
  Get-ChildItem $env:windir -Force | ?{$_.Name.StartsWith("$") -and $_.Name.EndsWith("$")} | %{ Remove-Item $env:windir\$_ -Recurse -Confirm:$false -Force }

  $ErrorActionPreference = 'Continue'

  Write-Output "Disc Clean up .. "
  # N.B. No way of knowing or specifying what options this will include!
  reg IMPORT Dev\PCprep-000-hklm-cleanmgr.reg 2>&1 | Out-Null
  cleanmgr.exe /sagerun:12357 /d $env:windir.SubString(0,1) | Out-Null

  ## Write-Output "System-wide TEMP folder .. "
  ## (not included with CleanMgr, but probably with CCleaner) where my temp stuff is:
  ## Jusr excluse items whose name begins with PCprep ?
  ## Get-ChildItem $windir:TEMP -Force | %{Remove-Item $windir:TEMP\$_ -Recurse -Confirm:$false -Force }
  ## Remove-Item -Recurse "$windir:TEMP\*" -Force

  Write-Output "Defrag .. "
  defrag $env:windir.SubString(0,2) > $OutDir/defrag.log
  defrag $env:windir.SubString(0,2) /X >> $OutDir/defrag.log
  # Modules\Start-DiskDefrag.ps1 -ComputerName localhost -DriveLetter $env:windir.SubString(0,1)

}
if($DeBug) { Write-Host " SoFar 39 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
