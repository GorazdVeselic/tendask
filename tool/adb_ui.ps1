# Drives the attached Android device for on-device smoke tests: optionally taps
# a point (or types text), then dumps the UI tree and prints every visible label
# with its bounds — so a run needs no screenshots.
#
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1 -Tap "540 1764"
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1 -Text "Kranj" -Wait 2
param(
  [string]$Tap = '',
  [string]$Text = '',
  [double]$Wait = 2,
  [switch]$Clickable
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path $root 'tmp'
if (-not (Test-Path $tmp)) { New-Item -ItemType Directory $tmp | Out-Null }
$local = Join-Path $tmp 'ui.xml'

if ($Tap) {
  $xy = $Tap -split '[ ,]+'
  adb shell input tap $xy[0] $xy[1] | Out-Null
}
if ($Text) {
  adb shell input text $Text | Out-Null
}
Start-Sleep -Seconds $Wait

adb shell uiautomator dump /sdcard/ui.xml | Out-Null
adb pull /sdcard/ui.xml $local | Out-Null

$xml = [xml](Get-Content $local -Raw)
$nodes = $xml.SelectNodes('//node')
if ($Clickable) { $nodes = $nodes | Where-Object { $_.clickable -eq 'true' } }
$nodes |
  Where-Object { $_.text -or $_.'content-desc' } |
  ForEach-Object {
    $label = ($_.text + $_.'content-desc') -replace "`n", ' / '
    '{0,-60} {1}' -f $label, $_.bounds
  }
