# health.tf

# Comprueba /healthz desde tu máquina (donde ejecutas Terraform)
data "external" "compose_health" {
  program = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "${path.module}/scripts/healthz.ps1"]

  # Consultamos al Nginx de la instancia
  query = {
    url     = "http://${module.backend.public_ip}/healthz"
    timeout = "6"
  }
}

# Mapa con los detalles del chequeo
output "compose_health" {
  value = {
    url       = data.external.compose_health.result["url"]
    status    = data.external.compose_health.result["status"]   # "up" | "degraded" | "down"
    http_code = data.external.compose_health.result["code"]
    body      = data.external.compose_health.result["body"]
  }
  description = "Estado de Docker Compose visto por /healthz (Nginx) desde el equipo que corre Terraform."
}

# Booleano directo por comodidad
output "compose_up" {
  value       = data.external.compose_health.result["status"] == "up"
  description = "true si /healthz devolvió 200 y 'ok'."
}
