import { ref } from 'vue'
import type { Task, TaskInput } from '@/types/task'
import { taskService } from '@/services/task.service'

export function useTasks() {
  const tasks = ref<Task[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function run<T>(fn: () => Promise<T>): Promise<T | undefined> {
    loading.value = true
    error.value = null
    try {
      return await fn()
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Error desconocido'
      return undefined
    } finally {
      loading.value = false
    }
  }

  async function fetchTasks() {
    const data = await run(() => taskService.list())
    if (data) tasks.value = data
  }

  async function createTask(input: TaskInput) {
    const created = await run(() => taskService.create(input))
    if (created) tasks.value.push(created)
    return created
  }

  async function updateTask(id: string, input: TaskInput) {
    const updated = await run(() => taskService.update(id, input))
    if (updated) {
      const i = tasks.value.findIndex((t) => t.id === id)
      if (i !== -1) tasks.value[i] = updated
    }
    return updated
  }

  async function toggleCompleted(task: Task) {
    if (!task.id) return
    await updateTask(task.id, {
      title: task.title,
      description: task.description,
      completed: !task.completed,
    })
  }

  async function deleteTask(id: string) {
    await run(() => taskService.remove(id))
    if (error.value === null) {
      tasks.value = tasks.value.filter((t) => t.id !== id)
    }
  }

  return { tasks, loading, error, fetchTasks, createTask, updateTask, toggleCompleted, deleteTask }
}
