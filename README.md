# MEVN + Terraform — Gestor de Tareas (proyecto de maestría)

Aplicación web CRUD de tareas con stack **MEVN** (MongoDB · Express · Vue · Node)
e infraestructura desplegada con **Terraform**.

## Estructura

| Carpeta | Responsable | Estado |
|---------|-------------|--------|
| `frontend/` | (tú) | Vue 3 + Vite — CRUD funcional ✅ |
| `backend/`  | compañero | Express + Mongoose — CRUD de `/api/tasks` ✅ |
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

## Guía de despliegue paso a paso

### 1. Prerrequisitos (una sola vez)

- AWS CLI configurado con credenciales que puedan crear VPC/EC2/ALB/IAM/S3
  (`aws sts get-caller-identity` para confirmar).
- Un Key Pair EC2 ya creado en la región a usar (por defecto `us-west-1`):
  ```bash
  aws ec2 create-key-pair --key-name mevn-tasks-keypair --region us-west-1 \
    --query 'KeyMaterial' --output text > mevn-tasks-keypair.pem
  chmod 400 mevn-tasks-keypair.pem
  ```
- Tu IP pública para `admin_cidr`: `curl ifconfig.me`

### 2. Compilar el frontend

El backend no necesita build (ya trae su código listo, ver tabla de arriba).

```bash
cd frontend
npm install
npm run build      # genera frontend/dist — sin esto, la capa web arranca sin contenido
```

### 3. Configurar variables de Terraform

```bash
cd ../infra
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars`: pon tu `admin_cidr` real y el `key_name` que creaste. Deja
`web_ami_id` / `backend_ami_id` / `db_ami_id` sin definir (se resuelven solos a la última
AMI pública correspondiente).

### 4. Desplegar

```bash
terraform init
terraform plan -out=tfplan     # revisa: debería decir "40 to add, 0 to change, 0 to destroy"
terraform apply tfplan
```

### 5. Esperar el bootstrap

Tras el `apply`, cada instancia tarda ~2-3 minutos en correr su `user_data` (instala
nginx/node, descarga el zip de S3, arranca el backend con pm2).

### 6. Verificar

```bash
terraform output load_balancer_dns
```

- Abre `http://<ese-dns>` en el navegador → debería cargar la app Vue.
- `curl http://<ese-dns>/api/tasks` → debería devolver `[]` (o las tareas, si ya hay datos).
- En la consola AWS: EC2 → Target Groups → el target group de web debería mostrar los 2
  targets como `healthy`.

### 7. Limitación conocida

Las instancias web/backend/db están en subredes privadas y no hay bastion host, así que
aunque el security group permite SSH desde tu `admin_cidr`, no hay forma de alcanzarlas
directamente para revisar `/var/log/user-data.log` si algo falla. Para depurar haría falta
agregar soporte para AWS Systems Manager Session Manager (no requiere abrir puertos ni
bastion) — pendiente si se necesita.

### 8. Destruir

Para no seguir pagando el NAT Gateway/ALB cuando no se use:

```bash
terraform destroy
```

## Pendientes del equipo

- **Decidir** si se renombra el repo a `MEVN_Terraform`.
