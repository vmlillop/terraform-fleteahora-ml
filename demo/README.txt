
# FleteAhora - Modo Tesis (Seeds + Postman)

Este paquete incluye:
- **FleteAhora_Tesis.postman_collection.json** → colección con 5 funcionalidades clave.
- **FleteAhora_Local.postman_environment.json** → ambiente opcional (baseUrl/puerto).
- **seed.sh** → script *idempotente* que siembra datos vía API con `curl`.

## 1) Requisitos
- Stack corriendo con el *modo tesis* (Docker Compose en tu EC2).
- Endpoints implementados según la propuesta:
  - `POST /auth/register`  body: `{name,email,password,role}`
  - `POST /auth/login`     body: `{email,password}` → retorna `token`
  - `GET /me`
  - `POST /cotizar`        body: `{origen{lat,lng},destino{lat,lng},pesoKg,tipoVehiculo}`
  - `POST /fletes`
  - `GET /fletes`, `GET /fletes/:id`
  - `POST /fletes/:id/asignar`
  - `PATCH /fletes/:id/estado` con estados: `ACEPTADO`, `EN_RECOGIDA`, `EN_RUTA`, `ENTREGADO`
- Mailhog expuesto en `:8025` (opcional para ver el correo simulado).

## 2) Uso rápido (script)
En tu EC2 o en tu equipo (si expones el puerto 80 públicamente):
```bash
bash seed.sh http://<IP-o-dominio> 80
# ejemplo local detrás de Nginx:
bash seed.sh http://127.0.0.1 80
```
Crea:
- 3 usuarios: **ADMIN**, **TRANSPORTISTA**, **CLIENTE**.
- 5 **fletes** de ejemplo.
- Asigna el primer flete y avanza su estado hasta **ENTREGADO**.

## 3) Postman
1. Importa `FleteAhora_Tesis.postman_collection.json`.
2. (Opcional) Importa el ambiente `FleteAhora_Local.postman_environment.json`.
3. Ajusta las variables `baseUrl` y `appPort` si tu API no está en `http://127.0.0.1:80`.
4. Ejecuta en orden la carpeta **01 - Autenticación y Roles**, luego **03 - Cotización**, **02 - Fletes**, **04 - Asignación y Estados**.
5. Verifica correos en **05 - Mailhog** (si tu backend envía notificación al entregar).

## 4) Notas
- Todos los requests son **idempotentes** en la práctica (si el backend retorna 409 en registros repetidos, no corta el flujo).
- Los scripts de prueba guardan tokens en variables de colección (`adminToken`, `transToken`, `cliToken`).
- Si ya tienes usuarios con esos correos, puedes cambiar `adminEmail`, `transEmail`, `cliEmail` en las variables de la colección.

¡Éxitos en la defensa! 💪
