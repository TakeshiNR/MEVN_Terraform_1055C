<script setup lang="ts">
import { onMounted } from 'vue'
import { useTasks } from '@/composables/useTasks'
import type { Task } from '@/types/task'

const { tasks, loading, error, fetchTasks, toggleCompleted, deleteTask } = useTasks()

onMounted(fetchTasks)

async function onDelete(task: Task) {
  if (!task.id) return
  if (window.confirm(`¿Eliminar "${task.title}"?`)) {
    await deleteTask(task.id)
  }
}
</script>

<template>
  <section>
    <div class="mb-6 flex items-center justify-between">
      <h1 class="text-2xl font-bold">Tareas</h1>
      <RouterLink
        to="/tasks/new"
        class="rounded-md bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700"
      >
        + Nueva tarea
      </RouterLink>
    </div>

    <p v-if="loading" class="text-slate-500">Cargando…</p>
    <p v-else-if="error" class="rounded-md bg-red-50 p-3 text-sm text-red-700">{{ error }}</p>
    <p
      v-else-if="tasks.length === 0"
      class="rounded-md border border-dashed border-slate-300 p-8 text-center text-slate-500"
    >
      No hay tareas todavía. ¡Crea la primera!
    </p>

    <ul v-else class="space-y-2">
      <li
        v-for="task in tasks"
        :key="task.id"
        class="flex items-center gap-3 rounded-lg border border-slate-200 bg-white p-4 shadow-sm"
      >
        <input
          type="checkbox"
          :checked="task.completed"
          class="h-5 w-5 shrink-0 rounded border-slate-300 text-indigo-600"
          @change="toggleCompleted(task)"
        />
        <div class="min-w-0 flex-1">
          <p
            :class="[
              'font-medium',
              task.completed ? 'text-slate-400 line-through' : 'text-slate-900',
            ]"
          >
            {{ task.title }}
          </p>
          <p v-if="task.description" class="truncate text-sm text-slate-500">
            {{ task.description }}
          </p>
        </div>
        <RouterLink
          :to="`/tasks/${task.id}/edit`"
          class="rounded px-2 py-1 text-sm text-indigo-600 hover:bg-indigo-50"
        >
          Editar
        </RouterLink>
        <button
          type="button"
          class="rounded px-2 py-1 text-sm text-red-600 hover:bg-red-50"
          @click="onDelete(task)"
        >
          Eliminar
        </button>
      </li>
    </ul>
  </section>
</template>
