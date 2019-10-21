$hostsPath = "$env:windir\System32\drivers\etc\hosts"
# $ip = (Get-NetIPAddress -InterfaceAlias "vEthernet (Default Switch)" -AddressFamily IPv4).IPAddress
$ip = (Get-VM 'vm-ubuntu').NetworkAdapters[0].IPAddresses[0]

# $ip = Read-Host -Prompt 'IP?'

$hosts = get-content $hostsPath
$hosts | ForEach-Object {if ($_ -match '^([\d | .]*)\s(.*\.dev.workfront.tech)$') 
                  {$ip + " " + $matches[2]} else {$_}} |
         Out-File $hostsPath -enc ascii

wsl --terminate Ubuntu-18.04
