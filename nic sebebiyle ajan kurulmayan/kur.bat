copy "C:\Users\exchange.admin\Desktop\ajan\ajan.ps1" \\%1\c$
wmic /node:"%1" process call create "cmd /c powershell -executionpolicy bypass c:\ajan.ps1"
del \\%1\c$\ajan.ps1