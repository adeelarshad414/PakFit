$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RootDir

$LogDir = Join-Path $RootDir "logs"
$PidFile = Join-Path $LogDir "dev-pids.txt"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

if (Test-Path $PidFile) {
  Get-Content $PidFile | ForEach-Object {
    if ($_ -match '^\d+$') {
      Stop-Process -Id ([int]$_) -Force -ErrorAction SilentlyContinue
    }
  }
  Set-Content -Path $PidFile -Value ""
}

$Ports = @()
if ($env:PAKFIT_DEV_PORTS) {
  $Ports = $env:PAKFIT_DEV_PORTS -split '\s+'
}

foreach ($Port in $Ports) {
  $Connections = netstat -ano | Select-String ":$Port\s"
  foreach ($Connection in $Connections) {
    $Parts = ($Connection.ToString() -split '\s+') | Where-Object { $_ }
    $Pid = $Parts[-1]
    if ($Pid -match '^\d+$') {
      Stop-Process -Id ([int]$Pid) -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Host "PakFit dev cleanup complete."
if ($Ports.Count -eq 0) {
  Write-Host "No fixed app ports are used by PakFit's native local workflow."
}
