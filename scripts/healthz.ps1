# scripts/healthz.ps1
Param()
$stdin = Get-Content -Raw -Encoding UTF8
$data = $stdin | ConvertFrom-Json

$url = $data.url
$timeout = [int]($data.timeout ?? 10)

try {
  $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec $timeout
  $ok = ($resp.StatusCode -eq 200 -and ($resp.Content.Trim() -match '^ok$'))
  $status = if ($ok) { "up" } else { "degraded" }
  $code = $resp.StatusCode
  $body = ($resp.Content.Trim() | Out-String).Trim()
} catch {
  $status = "down"
  $code = "-1"
  $body = $_.Exception.Message
}

@{
  status = $status
  code   = "$code"
  body   = $body
  url    = $url
} | ConvertTo-Json -Compress
