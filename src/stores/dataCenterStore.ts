import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'
import localDataCentersRaw from 'src/assets/cloudflare-iata-full.json?raw'
import type { DataCenter, DataCenterInfo } from 'src/types'

export const useDataCenterStore = defineStore('dataCenter', () => {
  const localDataCenters: Record<string, DataCenterInfo> = (
    JSON.parse(localDataCentersRaw) as DataCenter[]
  ).reduce(
    (acc, dc) => {
      acc[dc.slug] = { place: dc.place, lat: dc.lat, lng: dc.lng }
      return acc
    },
    {} as Record<string, DataCenterInfo>,
  )

  const dataCenters = ref<Record<string, DataCenterInfo>>(localDataCenters)
  const isLoading = ref(false)
  const hasFetched = ref(false)

  async function fetchDataCenters() {
    if (hasFetched.value || isLoading.value) {
      return
    }

    isLoading.value = true
    try {
      const response = await axios.get<DataCenter[]>(
        'https://cdn.jsdelivr.net/gh/insign/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata-full.json',
      )
      const fetchedData: Record<string, DataCenterInfo> = response.data.reduce(
        (acc, dc) => {
          acc[dc.slug] = { place: dc.place, lat: dc.lat, lng: dc.lng }
          return acc
        },
        {} as Record<string, DataCenterInfo>,
      )
      dataCenters.value = fetchedData
      hasFetched.value = true
    } catch (error) {
      console.error(
        'Failed to fetch updated Cloudflare data centers, using local fallback:',
        error,
      )
      hasFetched.value = true // Avoid refetching on every component mount in case of network issues.
    } finally {
      isLoading.value = false
    }
  }

  return {
    dataCenters,
    isLoading,
    fetchDataCenters,
  }
})