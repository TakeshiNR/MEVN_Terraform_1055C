import { createRouter, createWebHistory } from 'vue-router'
import TaskListView from '@/views/TaskListView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: '/tasks' },
    { path: '/tasks', name: 'tasks', component: TaskListView },
    {
      path: '/tasks/new',
      name: 'task-new',
      component: () => import('@/views/TaskFormView.vue'),
    },
    {
      path: '/tasks/:id/edit',
      name: 'task-edit',
      component: () => import('@/views/TaskFormView.vue'),
      props: true,
    },
  ],
})

export default router
