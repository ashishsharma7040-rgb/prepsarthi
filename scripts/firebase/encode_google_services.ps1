param(
  [Parameter(Mandatory = $true)]
  [string]$InputPath,

  [string]$OutputPath = "google-services.base64.txt"
)

if (-not (Test-Path -LiteralPath $InputPath)) {
  throw "Input file not found: $InputPath"
}

$json = Get-Content -LiteralPath $InputPath -Raw

if ($json -notmatch '"package_name"\s*:\s*"com\.prepsarthi\.app"') {
  Write-Warning "The selected google-services.json does not appear to match package com.prepsarthi.app."
}

$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
$base64 = [Convert]::ToBase64String($bytes)

Set-Content -LiteralPath $OutputPath -Value $base64 -NoNewline

Write-Host "Base64 written to: $OutputPath"
Write-Host "Use the file contents as Codemagic env var GOOGLE_SERVICES_JSON_B64 in group firebase_credentials."
