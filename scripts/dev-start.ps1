$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RootDir

$LogDir = Join-Path $RootDir "logs"
$PidFile = Join-Path $LogDir "dev-pids.txt"
$AndroidLog = Join-Path $LogDir "android-dev.log"
$SwiftLog = Join-Path $LogDir "ios-dev.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Set-Content -Path $PidFile -Value ""

function Require-Command($Name, $Hint) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name. Install hint: $Hint"
  }
}

Require-Command "java" "Install JDK 17."
if (-not (Test-Path (Join-Path $RootDir "gradlew.bat"))) {
  throw "Missing Gradle wrapper: gradlew.bat"
}

Write-Host "Building Android debug APK and running unit tests..."
& .\gradlew.bat --dependency-verification strict testDebugUnitTest assembleDebug *> $AndroidLog
if ($LASTEXITCODE -ne 0) {
  Get-Content $AndroidLog -Tail 80
  throw "Android validation failed. See $AndroidLog"
}

if (Get-Command "swift" -ErrorAction SilentlyContinue) {
  Write-Host "Running iOS Swift smoke tests and compiling PakFitApp..."
  Push-Location "ios/PakFitIOS"
  try {
    swift run PakFitCoreSmokeTests *> $SwiftLog
    if ($LASTEXITCODE -ne 0) { throw "Swift smoke tests failed." }
    swift build --target PakFitApp *>> $SwiftLog
    if ($LASTEXITCODE -ne 0) { throw "Swift app compile failed." }
  } finally {
    Pop-Location
  }
} else {
  Write-Host "Swift not found; skipping iOS Swift validation."
}

Write-Host "PakFit developer start summary"
Write-Host "Backend API: none - native local app only"
Write-Host "Frontend web: none - native Android and iOS"
Write-Host "Android debug APK: app/build/outputs/apk/debug/app-debug.apk"
Write-Host "No persistent services were started; logs/dev-pids.txt is intentionally empty."
