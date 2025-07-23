# Printer-WSD-to-IP
This will change a printer from WSD to IP using a printer name.

Change the info in WSD-to-IP.ps1 

* $PrinterName = "Your Printer Name" # Your Name of the printer how it is shown

* $NewIPAddress = "192.168.1.100" # Your Printer's IP


Using WSD-to-IP-Advance.ps1

```
.\WSD-to-IP-Advance.ps1 -PrinterName "Printer Name" -NewIPAddress "192.168.X.XXX"
```

----------------------------------------------------

 this script changes the printer configuration system-wide, which means:

 ✅ It affects all users on the computer, because:

Get-Printer and Set-Printer operate on the system's shared printer objects (under HKLM:\System\CurrentControlSet\Control\Print\Printers).

Printer port changes are not user-specific — they’re tied to the printer and apply for anyone who uses it on that machine.

🔒 Caveats:

You need to run the script as Administrator to have permission to modify printer ports and assignments.

If this is a shared printer on a server, any changes will also affect all client users pulling from that share.

If your goal is to apply this to all printers on all user profiles across a domain or fleet, that may require GPO, login scripts, or deployment tools.
