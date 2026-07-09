# MEVN + Terraform — Gestor de Tareas (proyecto de maestría)

Aplicación web CRUD de tareas con stack **MEVN** (MongoDB · Express · Vue · Node)
e infraestructura desplegada con **Terraform**.

## Estructura

| Carpeta | Responsable | Estado |
|---------|-------------|--------|
| `frontend/` | (tú) | Vue 3 + Vite — CRUD funcional ✅ |
| `backend/`  | compañero | vacío — API Express + Node/MongoDB |
| `infra/`    | compañero | Terraform (VPC, ALB, EC2 web/backend, MongoDB) ✅ |

## Frontend (implementado)

```bash
cd frontend
npm install
npm run mock   # API falsa (json-server) en :3000
npm run dev    # app Vite en :5173
```

Ver [`frontend/README.md`](frontend/README.md) para stack, scripts y el **contrato de API**
compartido con backend.

## Infraestructura (implementada)

Terraform en `infra/` levanta VPC + subredes (public/web/backend/db), security groups,
2 instancias web (Nginx) detrás de un ALB, 2 instancias backend (Express) y 1 instancia
MongoDB. El código de `frontend/` y `backend/` no se clona desde un repo: se empaqueta
localmente y se sube a S3, y cada instancia lo descarga en su arranque (ver
`infra/artifacts.tf` y `infra/scripts/*.sh.tpl`).

```bash
cd frontend && npm install && npm run build   # genera frontend/dist (requerido antes de apply)
cd ../infra
cp terraform.tfvars.example terraform.tfvars  # y rellena tus valores
terraform init
terraform plan
terraform apply
```

Nginx en la capa web sirve `frontend/dist` y reenvía `/api/` a la capa backend, coincidiendo
con `VITE_API_URL=/api/tasks` de `frontend/.env.production`.

## Pendientes del equipo

- **Backend:** implementar el contrato REST de `/tasks` (documentado en `frontend/README.md`),
  con `package.json` en la raíz de `backend/` (el `.env` con `MONGO_URI` se lo inyecta `infra/`
  automáticamente al arrancar). Serializar el `_id` de MongoDB como `id`.
- **Decidir** si se renombra el repo a `MEVN_Terraform`.
