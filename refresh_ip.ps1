$hostsPath = "$env:windir\System32\drivers\etc\hosts"
$ip = (Get-NetIPAddress -InterfaceAlias "vEthernet (Default Switch)" -AddressFamily IPv4).IPAddress

$hosts = get-content $hostsPath
$hosts | Foreach {if ($_ -match '^([\d | .]*)\s(.*\.dev.workfront.tech)$') 
                  {$ip + " " + $matches[2]} else {$_}} |
         Out-File $hostsPath -enc ascii

wsl --terminate Ubuntu-18.04
