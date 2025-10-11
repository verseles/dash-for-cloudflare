import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'
import localDataCentersRaw from 'src/assets/cloudflare-iata.json?raw'

export const useDataCenterStore = defineStore('dataCenter', () => {
  // Parse the raw string into a JavaScript object
  const localDataCenters = JSON.parse(localDataCentersRaw) as Record<string, string>

  // Initialize with the local JSON data for immediate availability
  const dataCenters = ref<Record<string, string>>(localDataCenters)
  const isLoading = ref(false)
  const hasFetched = ref(false)

  // Asynchronously fetch the latest data to update the store
  async function fetchDataCenters() {
    if (hasFetched.value || isLoading.value) {
      return
    }

    isLoading.value = true
    try {
      const response = await axios.get<Record<string, string>>(
        'https://cdn.jsdelivr.net/gh/LufsX/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata.json',
      )
      // Update the store with the latest data
      dataCenters.value = response.data
      hasFetched.value = true
    } catch (error) {
      console.error('Failed to fetch updated Cloudflare data centers, using local fallback:', error)
      // If the fetch fails, we'll continue using the pre-loaded local data.
      // We set hasFetched to true to avoid refetching on every component mount in case of network issues.
      hasFetched.value = true
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