<script setup lang="ts"></script>

<template>
  <div class="min-h-screen bg-slate-50 text-slate-900">
    <header class="border-b border-slate-200 bg-white">
      <div class="mx-auto flex max-w-3xl items-center justify-between px-4 py-4">
        <RouterLink to="/tasks" class="text-lg font-semibold">📋 Gestor de Tareas</RouterLink>
        <span class="text-xs text-slate-400">MEVN · Vue 3</span>
      </div>
    </header>

    <main class="mx-auto max-w-3xl px-4 py-8">
      <RouterView />
    </main>
  </div>
</template>
