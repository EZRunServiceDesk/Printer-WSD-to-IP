# Usage
# .\WSD-to-IP-Advance.ps1 -PrinterName "CFO Printer" -NewIPAddress "192.168.1.150"

# ============================
# PowerShell: Change Printer Port from WSD to RAW TCP/IP
# ============================

param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,

    [Parameter(Mandatory = $true)]
    [string]$NewIPAddress
)

# === SET VARIABLES ===
$newPortName = $NewIPAddress

# === GET CURRENT PRINTER ===
try {
    $printer = Get-Printer -Name $PrinterName -ErrorAction Stop
    $oldPortName = $printer.PortName
} catch {
    Write-Error "Printer '$PrinterName' not found."
    exit 1
}

# === CHECK IF CURRENT PORT IS WSD ===
if ($oldPortName -notmatch "^WSD") {
    Write-Host "Printer '$PrinterName' is not using a WSD port. Current port: $oldPortName"
} else {
    Write-Host "Replacing WSD port '$oldPortName' with IP '$NewIPAddress'..."
}

# === CREATE RAW TCP/IP PORT WITH WMI IF NOT EXISTS ===
$port = Get-WmiObject -Query "SELECT * FROM Win32_TCPIPPrinterPort WHERE Name = '$newPortName'" -ErrorAction SilentlyContinue

if (-not $port) {
    $createStatus = ([wmiclass]"Win32_TCPIPPrinterPort").Create(
        $newPortName,      # Name
        $NewIPAddress,     # HostAddress
        $false,            # SNMPEnabled
        9100,              # PortNumber
        "RAW",             # Protocol
        $NewIPAddress,     # Queue (same as HostAddress here)
        1                  # PortNumber again
    )

    if ($createStatus.ReturnValue -eq 0) {
        Write-Host "Created RAW port '$newPortName'"
    } else {
        Write-Error "Failed to create port. WMI return code: $($createStatus.ReturnValue)"
        exit 1
    }
} else {
    Write-Host "Port '$newPortName' already exists"
}

# === ASSIGN PRINTER TO NEW PORT ===
try {
    Set-Printer -Name $PrinterName -PortName $newPortName -ErrorAction Stop
    Write-Host "Printer '$PrinterName' is now using port '$newPortName'"
} catch {
    Write-Error "Failed to set printer port. $_"
    exit 1
}

# === OPTIONAL: REMOVE OLD WSD PORT ===
# Uncomment the next line if you want to delete the WSD port
# Remove-PrinterPort -Name $oldPortName -ErrorAction SilentlyContinue
