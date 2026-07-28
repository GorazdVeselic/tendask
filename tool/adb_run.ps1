# Runs a whole on-device scenario in ONE invocation, so a smoke test needs no
# per-command approval: the steps live in tmp/steps.txt (rewritten per run), the
# command line never changes.
#
#   powershell -ExecutionPolicy Bypass -File tool\adb_run.ps1
#
# -Steps runs a saved scenario instead, for sequences repeated across a session
# (sign-in, a threshold pass). -Vars fills {{NAME}} markers in it, so a scenario
# that needs a fresh value each run - an OTP code - stays a file, not a rewrite:
#
#   ... -File tool\adb_run.ps1 -Steps tmp\scenarios\login_code.txt -Vars OTP=123456
#
# -Vars takes NAME=VALUE pairs, not a hashtable: powershell -File passes every
# argument as a string, so a @{...} literal would arrive as the text
# "System.Collections.Hashtable".
#
# steps file - one step per line, '#' starts a comment:
#   taptext Nadaljuj         tap the element carrying this exact label (preferred)
#   tap 540 1916             tap a point (only for unlabelled elements, e.g. FAB)
#   text Bazilika            type into the focused field
#   key 67                   send a keyevent (67 = backspace)
#   swipe 540 1700 540 700   drag
#   wait 2                   pause, seconds
#   dump                     print every visible label with its bounds
#   shot 07_detail           save tmp/shots/07_detail.png (screencap)
#   echo some text           print a marker into the report
#
# A failing taptext stops the run and says which label was missing - a silent
# mis-tap is worse than a stop.
#
# Keep this file ASCII-only: PowerShell 5.1 reads .ps1 as ANSI, so a UTF-8 dash
# would decode into a smart quote and break the parse.
param(
  [string]$Steps = '',
  [string[]]$Vars = @()
)
$ErrorActionPreference = 'Stop'
$varMap = @{}
# Split on commas as well as across arguments: powershell -File binds every
# argument as ONE string, so "-Vars A=1,B=2" arrives as a single element and
# repeating -Vars is a binding error. Values therefore cannot contain a comma.
foreach ($entry in $Vars) {
  foreach ($pair in $entry.Split(',')) {
    if (-not $pair) { continue }
    $i = $pair.IndexOf('=')
    if ($i -lt 1) { throw "Bad -Vars entry '$pair' - expected NAME=VALUE." }
    $varMap[$pair.Substring(0, $i)] = $pair.Substring($i + 1)
  }
}
$root = Split-Path -Parent $PSScriptRoot
$stepsFile = if ($Steps) {
  if ([System.IO.Path]::IsPathRooted($Steps)) { $Steps } else { Join-Path $root $Steps }
} else {
  Join-Path $root 'tmp\steps.txt'
}
$uiFile = Join-Path $root 'tmp\ui.xml'

if (-not (Test-Path $stepsFile)) { throw "No steps file to run: $stepsFile" }

function Get-UiNodes {
  # No 2>&1 on these: PowerShell 5.1 turns a native command's stderr into a
  # terminating error, and adb reports a successful pull on stderr.
  adb shell uiautomator dump /sdcard/ui.xml | Out-Null
  adb pull /sdcard/ui.xml $uiFile | Out-Null
  # -Encoding UTF8: without it PS 5.1 reads the dump as ANSI and every Slovene
  # label turns to mojibake, so taptext never matches.
  ([xml](Get-Content $uiFile -Raw -Encoding UTF8)).SelectNodes('//node')
}

function Show-Screen {
  Get-UiNodes |
    Where-Object { $_.text -or $_.'content-desc' } |
    ForEach-Object {
      $label = ($_.text + $_.'content-desc') -replace "`n", ' / '
      '    {0,-58} {1}' -f $label, $_.bounds
    }
}

foreach ($line in Get-Content $stepsFile -Encoding UTF8) {
  $step = $line.Trim()
  if (-not $step -or $step.StartsWith('#')) { continue }
  foreach ($k in $varMap.Keys) { $step = $step.Replace("{{$k}}", $varMap[$k]) }
  # An unfilled marker would be typed verbatim into the app, and a wrong OTP
  # fails three screens later - stop where the cause is still visible.
  if ($step -match '\{\{(\w+)\}\}') { throw "Unfilled marker {{$($Matches[1])}} in $stepsFile" }

  $verb, $rest = $step -split '\s+', 2
  switch ($verb.ToLower()) {
    'taptext' {
      # A node's label can carry several lines (a nav tab reads "Dnevnik" plus
      # "Zavihek 3 od 4"), so match any single line exactly.
      $nodes = Get-UiNodes | Where-Object { $_.text -or $_.'content-desc' }
      $lineOf = {
        param($n)
        @($n.text, $n.'content-desc') |
          Where-Object { $_ } |
          ForEach-Object { $_ -split "`n" }
      }
      # Exact line first; fall back to a line containing the label, so an emoji
      # prefix ("✍️ Opombe") does not force the caller to reproduce it.
      $node = $nodes |
        Where-Object { (& $lineOf $_) -contains $rest } |
        Select-Object -First 1
      if (-not $node) {
        $node = $nodes |
          Where-Object { (& $lineOf $_) -like "*$rest*" } |
          Select-Object -First 1
      }
      if (-not $node) {
        Write-Output "FAIL taptext '$rest' - not on screen. Last screen:"
        Show-Screen
        exit 1
      }
      $b = [regex]::Matches($node.bounds, '\d+') | ForEach-Object { [int]$_.Value }
      adb shell input tap (($b[0] + $b[2]) / 2) (($b[1] + $b[3]) / 2) | Out-Null
      Write-Output "ok   taptext $rest"
      Start-Sleep -Milliseconds 1500
    }
    'tap' {
      $xy = $rest -split '[ ,]+'
      adb shell input tap $xy[0] $xy[1] | Out-Null
      Write-Output "ok   tap $rest"
      Start-Sleep -Milliseconds 1500
    }
    'text' {
      adb shell input text ($rest -replace ' ', '%s') | Out-Null
      Write-Output "ok   text $rest"
      Start-Sleep -Milliseconds 800
    }
    'key' {
      adb shell input keyevent $rest | Out-Null
      Write-Output "ok   key $rest"
      Start-Sleep -Milliseconds 500
    }
    'swipe' {
      $p = $rest -split '[ ,]+'
      adb shell input swipe $p[0] $p[1] $p[2] $p[3] 250 | Out-Null
      Write-Output "ok   swipe $rest"
      Start-Sleep -Milliseconds 1200
    }
    'wait' {
      Start-Sleep -Seconds ([double]$rest)
      Write-Output "ok   wait $rest"
    }
    'echo' { Write-Output "--- $rest" }
    'shot' {
      $shotDir = Join-Path $root 'tmp\shots'
      if (-not (Test-Path $shotDir)) { New-Item -ItemType Directory $shotDir | Out-Null }
      $path = Join-Path $shotDir "$rest.png"
      # cmd /c, not a PowerShell redirect: PS 5.1 pipes native output through a
      # text encoder and corrupts the PNG.
      cmd /c "adb exec-out screencap -p > `"$path`"" | Out-Null
      Write-Output "ok   shot tmp/shots/$rest.png"
    }
    'dump' {
      Write-Output "screen:"
      Show-Screen
    }
    default { throw "Unknown step '$verb' in tmp/steps.txt" }
  }
}
