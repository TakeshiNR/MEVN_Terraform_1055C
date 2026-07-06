import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { taskService } from '@/services/task.service'
import type { Task } from '@/types/task'

const fetchMock = vi.fn<typeof fetch>()

/** Construye una Response falsa con el cuerpo JSON indicado. */
function jsonResponse(body: unknown, ok = true, status = 200): Response {
  return {
    ok,
    status,
    statusText: ok ? 'OK' : 'Error',
    text: () => Promise.resolve(body === null ? '' : JSON.stringify(body)),
  } as unknown as Response
}

describe('taskService', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', fetchMock)
    fetchMock.mockReset()
  })
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('list() hace GET y devuelve las tareas', async () => {
    const tasks: Task[] = [{ id: '1', title: 'Test', completed: false }]
    fetchMock.mockResolvedValue(jsonResponse(tasks))

    const result = await taskService.list()

    expect(result).toEqual(tasks)
    expect(fetchMock).toHaveBeenCalledOnce()
  })

  it('create() hace POST con el cuerpo en JSON', async () => {
    const created: Task = { id: '9', title: 'Nueva', completed: false }
    fetchMock.mockResolvedValue(jsonResponse(created))

    const result = await taskService.create({ title: 'Nueva', completed: false })

    expect(result).toEqual(created)
    const [, options] = fetchMock.mock.calls[0]!
    expect(options?.method).toBe('POST')
    expect(JSON.parse(options?.body as string)).toMatchObject({ title: 'Nueva', completed: false })
  })

  it('remove() hace DELETE y tolera cuerpo vacío', async () => {
    fetchMock.mockResolvedValue(jsonResponse(null))

    await expect(taskService.remove('1')).resolves.toBeNull()
    const [, options] = fetchMock.mock.calls[0]!
    expect(options?.method).toBe('DELETE')
  })

  it('lanza error cuando la respuesta no es ok', async () => {
    fetchMock.mockResolvedValue(jsonResponse(null, false, 500))

    await expect(taskService.list()).rejects.toThrow('Error 500')
  })
})
