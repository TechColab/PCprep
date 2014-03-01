echo "Getting online .. "

Push-Location
if($DeBug) { Write-Host " SoFar 4 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
cd "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

if ( $false) { # No Proxy
set-itemproperty . ProxyEnable 0
set-itemproperty . ProxyServer ""
# set-itemproperty . ProxyOverride "<local>"
# new-itemproperty . AutoConfigURL
# set-itemproperty . AutoConfigURL <autoconfig url>
}

if ( $false ) { # 2e2 user LAN
set-itemproperty . ProxyEnable 1
set-itemproperty . ProxyServer "192.168.106.249:8080"
# set-itemproperty . ProxyOverride "<local>"
# new-itemproperty . AutoConfigURL
# set-itemproperty . AutoConfigURL <autoconfig url>
}

if ( $false ) { # 2e2 build-room LAN
set-itemproperty . ProxyEnable 1
set-itemproperty . ProxyServer "192.168.2.254:8080"
# set-itemproperty . ProxyOverride "<local>"
# new-itemproperty . AutoConfigURL
# set-itemproperty . AutoConfigURL <autoconfig url>
}

if ( $true ) { # TechColab
set-itemproperty . ProxyEnable 1
set-itemproperty . ProxyServer "192.168.7.110:3128"
# set-itemproperty . ProxyOverride "<local>"
# new-itemproperty . AutoConfigURL
# set-itemproperty . AutoConfigURL <autoconfig url>
}

Pop-Location
if($DeBug) { Write-Host " SoFar 40 " ; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") }
