# Frontend — Gestor de Tareas (MEVN)

SPA de un CRUD de **tareas (To-Do)**. Es la capa de presentación del proyecto MEVN
(MongoDB · Express · **Vue** · Node) con despliegue vía Terraform.

> El stack se cambió de Angular (MEAN) a **Vue (MEVN)** por ser más ligero e ideal para un
> CRUD pequeño. La rúbrica no exige Angular.

## Stack

| Área | Elección |
|------|----------|
| Framework | Vue 3 (`<script setup>`, Composition API) |
| Build tool | Vite |
| Lenguaje | TypeScript (strict) |
| Estilos | Tailwind CSS v4 (plugin `@tailwindcss/vite`) |
| Estado | Composables + `ref` (sin Pinia — innecesario para una entidad) |
| Ruteo | Vue Router |
| HTTP | `fetch` nativo, envuelto en `src/services/task.service.ts` |
| Mock de API | json-server (`npm run mock`) |
| Tests | Vitest + Vue Test Utils |
| Calidad | ESLint (+ oxlint) + Prettier |

## Cómo correr en desarrollo

Requiere Node `^22.18.0 || >=24.12.0`.

```bash
npm install          # instalar dependencias
npm run mock         # terminal 1: API falsa en http://localhost:3000
npm run dev          # terminal 2: app Vite (imprime la URL, normalmente :5173)
```

Abre la URL de Vite: podrás crear, listar, editar, completar y eliminar tareas;
los cambios se guardan en `db.json`.

## Scripts

| Script | Qué hace |
|--------|----------|
| `npm run dev` | Servidor de desarrollo (HMR) |
| `npm run mock` | json-server sobre `db.json` en el puerto 3000 |
| `npm run build` | Build de producción → `dist/` |
| `npm run preview` | Sirve el `dist/` compilado |
| `npm run test:unit` | Pruebas unitarias (Vitest) |
| `npm run lint` | oxlint + ESLint con `--fix` |
| `npm run format` | Prettier |

## Configuración por entorno

La URL del API es configurable y **desacopla el frontend de la decisión de infra**:

- `.env` → `VITE_API_URL=http://localhost:3000/tasks` (dev, json-server)
- `.env.production` → placeholder que **infra** define/inyecta en el build

Se lee en el código como `import.meta.env.VITE_API_URL`.

## Contrato de API (fuente de verdad frontend ↔ backend)

Base URL configurable (`VITE_API_URL`). Rutas REST estándar:

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET    | `/tasks`      | Lista todas las tareas |
| GET    | `/tasks/:id`  | Una tarea |
| POST   | `/tasks`      | Crea. Body: `{ title, description?, completed }` |
| PUT    | `/tasks/:id`  | Actualiza. Body: `{ title, description?, completed }` |
| DELETE | `/tasks/:id`  | Elimina |

Modelo `Task`:

```ts
interface Task {
  id?: string          // identificador
  title: string
  description?: string
  completed: boolean
  createdAt?: string   // ISO, lo genera el backend
  updatedAt?: string   // ISO, lo genera el backend
}
```

**Acuerdo importante con backend:** el frontend usa `id`. El backend (MongoDB/Mongoose)
debe serializar su `_id` como `id` (transform `toJSON`), para que mock y backend real
compartan la misma forma. Pendiente por definir con el equipo: ¿ruta `/tasks` o `/api/tasks`?

## Estructura

```
src/
├── types/task.ts               # modelo Task + TaskInput
├── services/task.service.ts    # CRUD con fetch → VITE_API_URL
├── composables/useTasks.ts     # estado reactivo + acciones
├── views/
│   ├── TaskListView.vue        # lista + toggle + eliminar
│   └── TaskFormView.vue        # crear / editar (validación)
├── router/index.ts
├── App.vue
└── main.ts
```

## Despliegue (para infra)

`npm run build` genera artefactos estáticos en **`frontend/dist/`**. Ese directorio es lo que
Terraform debe publicar (S3/CloudFront, Nginx, etc.). La URL del API se fija vía `.env.production`
o inyectando `VITE_API_URL` en el paso de build.
