#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1}"
PORT="${2:-80}"

header_json=(-H "Content-Type: application/json")

say(){ echo -e "\033[1;32m==>\033[0m $*"; }

# Register users (idempotente: si existen, el backend debería responder 409 sin romper el flujo)
say "Registrando usuarios demo..."
curl -sS "${BASE_URL}:${PORT}/auth/register" "${header_json[@]}" -d '{"name":"Admin Demo","email":"admin@demo.cl","password":"Demo1234!","role":"ADMIN"}' >/dev/null || true
curl -sS "${BASE_URL}:${PORT}/auth/register" "${header_json[@]}" -d '{"name":"Trans Demo","email":"trans@demo.cl","password":"Demo1234!","role":"TRANSPORTISTA"}' >/dev/null || true
curl -sS "${BASE_URL}:${PORT}/auth/register" "${header_json[@]}" -d '{"name":"Cliente Demo","email":"cliente@demo.cl","password":"Demo1234!","role":"CLIENTE"}' >/dev/null || true

# Login to capture tokens
say "Haciendo login para capturar tokens..."
ADMIN_TOKEN=$(curl -sS "${BASE_URL}:${PORT}/auth/login" "${header_json[@]}" -d '{"email":"admin@demo.cl","password":"Demo1234!"}' | jq -r '.token // .accessToken')
TRANS_TOKEN=$(curl -sS "${BASE_URL}:${PORT}/auth/login" "${header_json[@]}" -d '{"email":"trans@demo.cl","password":"Demo1234!"}' | jq -r '.token // .accessToken')
CLI_TOKEN=$(curl -sS "${BASE_URL}:${PORT}/auth/login" "${header_json[@]}" -d '{"email":"cliente@demo.cl","password":"Demo1234!"}' | jq -r '.token // .accessToken')

# Create 5 demo fletes (cliente)
say "Creando fletes demo (5)..."
create_flete(){
  local olat="$1" olng="$2" dlat="$3" dlng="$4" peso="$5" tipo="$6" fecha="$7"
  local precio=$(curl -sS "${BASE_URL}:${PORT}/cotizar" "${header_json[@]}" -H "Authorization: Bearer ${CLI_TOKEN}" -d "{\"origen\": {\"lat\": ${olat}, \"lng\": ${olng}}, \"destino\": {\"lat\": ${dlat}, \"lng\": ${dlng}}, \"pesoKg\": ${peso}, \"tipoVehiculo\": \"${tipo}\"}" | jq -r '.precioEstimado')
  curl -sS "${BASE_URL}:${PORT}/fletes" "${header_json[@]}" -H "Authorization: Bearer ${CLI_TOKEN}" -d "{\"origenLat\": ${olat}, \"origenLng\": ${olng}, \"destinoLat\": ${dlat}, \"destinoLng\": ${dlng}, \"pesoKg\": ${peso}, \"tipoVehiculo\": \"${tipo}\", \"fecha\": \"${fecha}\", \"precioEstimado\": ${precio}}" | jq -r '.id // .flete.id'
}

F1=$(create_flete -33.45694 -70.64827 -33.4372 -70.6506 120 camioneta "2025-08-20T09:00:00.000Z")
F2=$(create_flete -33.46912 -70.64197 -33.5153 -70.6666 350 camion "2025-08-20T11:00:00.000Z")
F3=$(create_flete -33.43050 -70.62000 -33.4522 -70.6800 80 pickup "2025-08-20T13:00:00.000Z")
F4=$(create_flete -33.48010 -70.70000 -33.4100 -70.5600 200 camioneta "2025-08-21T09:30:00.000Z")
F5=$(create_flete -33.52000 -70.62000 -33.4800 -70.6100 50 pickup "2025-08-21T16:00:00.000Z")

say "Asignando F1 al transportista y avanzando estados..."
curl -sS -X POST "${BASE_URL}:${PORT}/fletes/${F1}/asignar" "${header_json[@]}" -H "Authorization: Bearer ${ADMIN_TOKEN}" -d '{}' >/dev/null || true
for estado in ACEPTADO EN_RECOGIDA EN_RUTA ENTREGADO; do
  curl -sS -X PATCH "${BASE_URL}:${PORT}/fletes/${F1}/estado" "${header_json[@]}" -H "Authorization: Bearer ${TRANS_TOKEN}" -d "{\"estado\":\"${estado}\"}" >/dev/null || true
done

say "Listo. Revisa Mailhog en ${BASE_URL}:8025 (si tu backend envía correo al ENTREGADO)."
say "IDs creados: F1=${F1}, F2=${F2}, F3=${F3}, F4=${F4}, F5=${F5}"
