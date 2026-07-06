# MEVN + Terraform — Gestor de Tareas (proyecto de maestría)

Aplicación web CRUD de tareas con stack **MEVN** (MongoDB · Express · Vue · Node)
e infraestructura desplegada con **Terraform**.

## Estructura

| Carpeta | Responsable | Estado |
|---------|-------------|--------|
| `frontend/` | (tú) | Vue 3 + Vite — CRUD funcional ✅ |
| `backend/`  | compañero | vacío — API Express + Node/MongoDB |
| `infra/`    | compañero | vacío — Terraform |

## Frontend (implementado)

```bash
cd frontend
npm install
npm run mock   # API falsa (json-server) en :3000
npm run dev    # app Vite en :5173
```

Ver [`frontend/README.md`](frontend/README.md) para stack, scripts y el **contrato de API**
compartido con backend.

## Pendientes del equipo

- **Backend:** implementar el contrato REST de `/tasks` (documentado en `frontend/README.md`).
  Serializar el `_id` de MongoDB como `id`.
- **Infra:** publicar `frontend/dist/` (S3/CloudFront, Nginx, etc.) e inyectar `VITE_API_URL` en el build.
- **Acordar** la ruta base del API: `/tasks` vs `/api/tasks`.
- **Decidir** si se renombra el repo a `MEVN_Terraform`.
