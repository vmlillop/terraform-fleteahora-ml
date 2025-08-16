# scripts/healthz.ps1  (compatible con Windows PowerShell 5.1)
Param()

# Lee el JSON de stdin
$stdin = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($stdin)) { $stdin = "{}" }
$data = $stdin | ConvertFrom-Json

# URL a consultar
$url = $data.url
if (-not $url) { $url = "http://127.0.0.1/healthz" }

# Timeout por defecto 10s (sin '??')
$timeout = 10
if ($data -and $data.PSObject.Properties.Name -contains 'timeout' -and $data.timeout) {
  try { $timeout = [int]$data.timeout } catch { $timeout = 10 }
}

try {
  # -UseBasicParsing es necesario en PS 5.1
  $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec $timeout
  $bodyText = ($resp.Content | Out-String).Trim()
  $ok = ($resp.StatusCode -eq 200 -and $bodyText -match '^ok$')
  $status = if ($ok) { "up" } elseif ($resp.StatusCode -eq 200) { "degraded" } else { "down" }
  $code = [string]$resp.StatusCode
} catch {
  $status = "down"
  $code = "-1"
  $bodyText = $_.Exception.Message
}

@{
  status = $status
  code   = $code
  body   = $bodyText
  url    = $url
} | ConvertTo-Json -Compress
