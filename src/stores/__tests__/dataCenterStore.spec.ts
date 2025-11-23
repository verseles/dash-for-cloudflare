import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useDataCenterStore } from '../dataCenterStore'
import axios from 'axios'

// Mock axios
vi.mock('axios')
const mockedAxios = vi.mocked(axios)

describe('dataCenterStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('should have initial data from local JSON', () => {
    const store = useDataCenterStore()
    // Should have some data from local fallback
    expect(store.dataCenters).toBeDefined()
    expect(typeof store.dataCenters).toBe('object')
    expect(store.isLoading).toBe(false)
  })

  it('should fetch data centers from CDN', async () => {
    const mockData = {
      LAX: { iata: 'LAX', city: 'Los Angeles', country: 'US' },
      GRU: { iata: 'GRU', city: 'São Paulo', country: 'BR' }
    }

    mockedAxios.get.mockResolvedValueOnce({ data: mockData })

    const store = useDataCenterStore()
    await store.fetchDataCenters()

    expect(mockedAxios.get).toHaveBeenCalledWith(
      'https://cdn.jsdelivr.net/gh/insign/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata-full.json'
    )
    expect(store.dataCenters).toEqual(mockData)
    expect(store.isLoading).toBe(false)
  })

  it('should not refetch if already fetched', async () => {
    const mockData = { LAX: { iata: 'LAX', city: 'Los Angeles', country: 'US' } }
    mockedAxios.get.mockResolvedValueOnce({ data: mockData })

    const store = useDataCenterStore()
    await store.fetchDataCenters()
    await store.fetchDataCenters() // Second call

    expect(mockedAxios.get).toHaveBeenCalledTimes(1)
  })

  it('should handle fetch error gracefully', async () => {
    mockedAxios.get.mockRejectedValueOnce(new Error('Network error'))

    const store = useDataCenterStore()
    const originalData = { ...store.dataCenters }

    await store.fetchDataCenters()

    // Should keep local fallback data on error
    expect(store.dataCenters).toEqual(originalData)
    expect(store.isLoading).toBe(false)
  })
})
