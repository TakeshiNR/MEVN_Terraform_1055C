/**
 * Modelo de una tarea (To-Do).
 *
 * Nota de contrato: el frontend usa `id` como identificador. El backend (MongoDB)
 * debe serializar su `_id` como `id` (transform `toJSON` estándar en Mongoose).
 * Así el mock (json-server) y el backend real comparten la misma forma.
 */
export interface Task {
  id?: string
  title: string
  description?: string
  completed: boolean
  createdAt?: string
  updatedAt?: string
}

/** Campos que el usuario captura en el formulario (el backend genera id y fechas). */
export type TaskInput = Pick<Task, 'title' | 'description' | 'completed'>
