# Backend - Gestor de Tareas

## Tecnologías

- Node.js
- Express
- MongoDB
- Mongoose
- Dotenv
- CORS

## Instalación

```bash
npm install
```

## Variables de entorno

Crear un archivo `.env`:

```env
PORT=3000
MONGO_URI=mongodb://localhost:27017/gestor_tareas
```

## Ejecutar

```bash
npm run dev
```

## Endpoints

### Obtener tareas

GET /api/tasks

### Crear tarea

POST /api/tasks

### Actualizar tarea

PUT /api/tasks/:id

### Eliminar tarea

DELETE /api/tasks/:id
