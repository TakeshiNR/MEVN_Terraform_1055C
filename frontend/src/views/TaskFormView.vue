<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { taskService } from '@/services/task.service'
import type { TaskInput } from '@/types/task'

const props = defineProps<{ id?: string }>()
const router = useRouter()

const isEdit = computed(() => !!props.id)
const loading = ref(false)
const error = ref<string | null>(null)
const titleError = ref<string | null>(null)

const form = reactive<TaskInput>({
  title: '',
  description: '',
  completed: false,
})

onMounted(async () => {
  if (!props.id) return
  loading.value = true
  try {
    const task = await taskService.get(props.id)
    form.title = task.title
    form.description = task.description ?? ''
    form.completed = task.completed
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudo cargar la tarea'
  } finally {
    loading.value = false
  }
})

function validate(): boolean {
  titleError.value =
    form.title.trim().length < 3 ? 'El título debe tener al menos 3 caracteres.' : null
  return titleError.value === null
}

async function onSubmit() {
  if (!validate()) return
  loading.value = true
  error.value = null
  const payload: TaskInput = {
    title: form.title.trim(),
    description: form.description?.trim() || undefined,
    completed: form.completed,
  }
  try {
    if (props.id) {
      await taskService.update(props.id, payload)
    } else {
      await taskService.create(payload)
    }
    router.push('/tasks')
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'No se pudo guardar la tarea'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="mx-auto max-w-lg">
    <h1 class="mb-6 text-2xl font-bold">{{ isEdit ? 'Editar tarea' : 'Nueva tarea' }}</h1>

    <p v-if="error" class="mb-4 rounded-md bg-red-50 p-3 text-sm text-red-700">{{ error }}</p>

    <form class="space-y-4" @submit.prevent="onSubmit">
      <div>
        <label for="title" class="mb-1 block text-sm font-medium text-slate-700">Título</label>
        <input
          id="title"
          v-model="form.title"
          type="text"
          class="w-full rounded-md border border-slate-300 px-3 py-2 focus:border-indigo-500 focus:outline-none"
          placeholder="¿Qué hay que hacer?"
        />
        <p v-if="titleError" class="mt-1 text-sm text-red-600">{{ titleError }}</p>
      </div>

      <div>
        <label for="description" class="mb-1 block text-sm font-medium text-slate-700">
          Descripción
        </label>
        <textarea
          id="description"
          v-model="form.description"
          rows="3"
          class="w-full rounded-md border border-slate-300 px-3 py-2 focus:border-indigo-500 focus:outline-none"
          placeholder="Detalles (opcional)"
        ></textarea>
      </div>

      <label class="flex items-center gap-2 text-sm text-slate-700">
        <input
          v-model="form.completed"
          type="checkbox"
          class="h-4 w-4 rounded border-slate-300 text-indigo-600"
        />
        Completada
      </label>

      <div class="flex gap-3 pt-2">
        <button
          type="submit"
          :disabled="loading"
          class="rounded-md bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
        >
          {{ loading ? 'Guardando…' : 'Guardar' }}
        </button>
        <RouterLink
          to="/tasks"
          class="rounded-md px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100"
        >
          Cancelar
        </RouterLink>
      </div>
    </form>
  </section>
</template>
