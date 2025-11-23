import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { nextTick } from 'vue'

// Mock LocalStorage
const mockLocalStorage = new Map<string, unknown>()
vi.mock('quasar', async (importOriginal) => {
  const actual = await importOriginal<typeof import('quasar')>()
  return {
    ...actual,
    LocalStorage: {
      getItem: (key: string) => mockLocalStorage.get(key) ?? null,
      set: (key: string, value: unknown) => mockLocalStorage.set(key, value),
      remove: (key: string) => mockLocalStorage.delete(key)
    }
  }
})

// Mock useSettings - needs to return reactive object for watch to work
let mockApiToken = ''
vi.mock('src/composables/useSettings', () => ({
  useSettings: () => ({
    settings: {
      get cloudflareApiToken() {
        return mockApiToken
      }
    }
  })
}))

// Mock useCloudflareApi
const mockGetZones = vi.fn()
vi.mock('src/composables/useCloudflareApi', () => ({
  useCloudflareApi: () => ({
    getZones: mockGetZones
  })
}))

// Mock loading store
vi.mock('src/stores/loading', () => ({
  useLoadingStore: () => ({
    startLoading: vi.fn(),
    stopLoading: vi.fn()
  })
}))

describe('zoneStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
    mockLocalStorage.clear()
    mockApiToken = ''
  })

  it('should have correct initial state with empty token', async () => {
    const { useZoneStore } = await import('../zoneStore')
    const store = useZoneStore()
    await nextTick()

    expect(store.zones).toEqual([])
    expect(store.isLoadingZones).toBe(false)
  })

  it('should require valid API token to fetch zones', async () => {
    mockApiToken = 'short-token'

    const { useZoneStore } = await import('../zoneStore')
    const store = useZoneStore()
    await store.fetchZones()

    expect(store.operationError).toBe('A valid Cloudflare API Token is required.')
    expect(mockGetZones).not.toHaveBeenCalled()
  })

  it('should call getZones when fetchZones is called with valid token', async () => {
    const mockZones = [
      { id: 'zone-1', name: 'example.com' },
      { id: 'zone-2', name: 'test.com' }
    ]
    mockGetZones.mockResolvedValue(mockZones)
    mockApiToken = 'valid-api-token-that-is-at-least-40-characters-long'

    const { useZoneStore } = await import('../zoneStore')
    const store = useZoneStore()

    // Wait for any immediate watch to settle
    await nextTick()
    await new Promise((r) => setTimeout(r, 10))

    // Manually call fetchZones to ensure our mock is used
    await store.fetchZones()

    expect(mockGetZones).toHaveBeenCalled()
  })

  it('should handle fetch error', async () => {
    mockGetZones.mockRejectedValue(new Error('API Error'))
    mockApiToken = 'valid-api-token-that-is-at-least-40-characters-long'

    const { useZoneStore } = await import('../zoneStore')
    const store = useZoneStore()
    await store.fetchZones()

    expect(store.zones).toEqual([])
    expect(store.operationError).toContain('Failed to fetch zones')
  })

  it('should set loading state during fetch', async () => {
    mockGetZones.mockImplementation(
      () => new Promise((resolve) => setTimeout(() => resolve([]), 50))
    )
    mockApiToken = 'valid-api-token-that-is-at-least-40-characters-long'

    const { useZoneStore } = await import('../zoneStore')
    const store = useZoneStore()

    const fetchPromise = store.fetchZones()
    expect(store.isLoadingZones).toBe(true)

    await fetchPromise
    expect(store.isLoadingZones).toBe(false)
  })
})
