# === USER SET VARIABLES ===
$PrinterName = "Your Printer Name"
$NewIPAddress = "192.168.1.100"  # Replace this with the actual IP address

# === GET CURRENT PRINTER ===
$printer = Get-Printer -Name $PrinterName -ErrorAction Stop
$oldPortName = $printer.PortName

# === CHECK IF CURRENT PORT IS WSD ===
if ($oldPortName -notmatch "^WSD") {
    Write-Host "Printer '$PrinterName' is not using a WSD port. Current port: $oldPortName"
} else {
    Write-Host "Replacing WSD port '$oldPortName' with IP '$NewIPAddress'..."
}

# === SET NEW PORT NAME BASED ON IP ===
$newPortName = $NewIPAddress

# === CREATE NEW TCP/IP PORT IF NEEDED ===
if (-not (Get-PrinterPort -Name $newPortName -ErrorAction SilentlyContinue)) {
    Add-PrinterPort -Name $newPortName -PrinterHostAddress $NewIPAddress -PortNumber 9100 -Protocol Raw
    Write-Host "Created new port '$newPortName'"
} else {
    Write-Host "Port '$newPortName' already exists"
}

# === ASSIGN PRINTER TO NEW PORT ===
Set-Printer -Name $PrinterName -PortName $newPortName
Write-Host "Printer '$PrinterName' is now using port '$newPortName'"

# === OPTIONAL: REMOVE OLD WSD PORT ===
# Remove-PrinterPort -Name $oldPortName -ErrorAction SilentlyContinue
