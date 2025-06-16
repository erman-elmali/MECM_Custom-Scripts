Get-NetAdapter | out-file c:\adaptor.txt


Get-NetAdapter | where InterfaceDescription -Like "*Npcap Loopback Adapter*" | Disable-NetAdapter -Confirm:$false
Get-NetAdapter | where InterfaceDescription -Like "*Hyper-V Virtual Ethernet*" | Disable-NetAdapter -Confirm:$false
net stop ccmsetup
taskkill /f /im ccmsetup.exe
md C:\Windows\ccmsetup
copy \\bilgem.net\NETLOGON\ccmsetup\ccmsetup.exe C:\Windows\ccmsetup
. "c:\windows\ccmsetup\ccmsetup.exe" SMSSITECODE=GBZ FSP=MECM-SS-01.bilgem.net SMSMP=MECM-SS-01.bilgem.net RESETKEYINFORMATION=True /mp:MECM-SS-01.bilgem.net

ping 127.0.0.1 -n 30

Get-NetAdapter | where InterfaceDescription -Like "*Hyper-V Virtual Ethernet*" | Enable-NetAdapter -Confirm:$false
Get-NetAdapter | where name -Like "*Npcap Loopback Adapter*" | Enable-NetAdapter -Confirm:$false
Get-NetAdapter | out-file c:\adaptor1.txt
