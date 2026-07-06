/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** URL base del recurso de tareas del API (ver .env). */
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
