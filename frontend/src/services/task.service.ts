import type { Task, TaskInput } from '@/types/task'

const API_URL = import.meta.env.VITE_API_URL

const JSON_HEADERS = { 'Content-Type': 'application/json' }

async function handle<T>(res: Response): Promise<T> {
  if (!res.ok) {
    throw new Error(`Error ${res.status}: ${res.statusText}`)
  }
  const text = await res.text()
  return (text ? JSON.parse(text) : null) as T
}

export const taskService = {
  list(): Promise<Task[]> {
    return fetch(API_URL).then((r) => handle<Task[]>(r))
  },

  get(id: string): Promise<Task> {
    return fetch(`${API_URL}/${id}`).then((r) => handle<Task>(r))
  },

  create(task: TaskInput): Promise<Task> {
    return fetch(API_URL, {
      method: 'POST',
      headers: JSON_HEADERS,
      body: JSON.stringify(task),
    }).then((r) => handle<Task>(r))
  },

  update(id: string, task: TaskInput): Promise<Task> {
    return fetch(`${API_URL}/${id}`, {
      method: 'PUT',
      headers: JSON_HEADERS,
      body: JSON.stringify(task),
    }).then((r) => handle<Task>(r))
  },

  remove(id: string): Promise<void> {
    return fetch(`${API_URL}/${id}`, { method: 'DELETE' }).then((r) => handle<void>(r))
  },
}
