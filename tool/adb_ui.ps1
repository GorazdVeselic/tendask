# Drives the attached Android device for on-device smoke tests: optionally taps
# a label (or a point, or types text), then dumps the UI tree and prints every
# visible label with its bounds — so a run needs no screenshots.
#
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1 -TapText "Opravila"
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1 -Tap "540 1764"
#   powershell -ExecutionPolicy Bypass -File tool\adb_ui.ps1 -Text "Kranj" -Wait 2
#
# Prefer -TapText: a step written as a label survives a layout change, while a
# recorded coordinate silently taps the wrong thing. -Tap stays for the elements
# that carry no label at all (FAB, bare icons).
param(
  [string]$Tap = '',
  [string]$TapText = '',
  [string]$Text = '',
  [double]$Wait = 2,
  [switch]$Clickable
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path $root 'tmp'
if (-not (Test-Path $tmp)) { New-Item -ItemType Directory $tmp | Out-Null }
$local = Join-Path $tmp 'ui.xml'

function Get-UiNodes {
  adb shell uiautomator dump /sdcard/ui.xml | Out-Null
  adb pull /sdcard/ui.xml $local | Out-Null
  ([xml](Get-Content $local -Raw)).SelectNodes('//node')
}

if ($TapText) {
  $match = Get-UiNodes |
    Where-Object { $_.text -eq $TapText -or $_.'content-desc' -eq $TapText } |
    Select-Object -First 1
  if (-not $match) { throw "No element labelled '$TapText' on screen." }
  # bounds are "[x1,y1][x2,y2]" — tap the centre.
  $n = [regex]::Matches($match.bounds, '\d+') | ForEach-Object { [int]$_.Value }
  adb shell input tap (($n[0] + $n[2]) / 2) (($n[1] + $n[3]) / 2) | Out-Null
}
if ($Tap) {
  $xy = $Tap -split '[ ,]+'
  adb shell input tap $xy[0] $xy[1] | Out-Null
}
if ($Text) {
  adb shell input text $Text | Out-Null
}
Start-Sleep -Seconds $Wait

$nodes = Get-UiNodes
if ($Clickable) { $nodes = $nodes | Where-Object { $_.clickable -eq 'true' } }
$nodes |
  Where-Object { $_.text -or $_.'content-desc' } |
  ForEach-Object {
    $label = ($_.text + $_.'content-desc') -replace "`n", ' / '
    '{0,-60} {1}' -f $label, $_.bounds
  }
