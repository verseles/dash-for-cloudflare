import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'

export const useDataCenterStore = defineStore('dataCenter', () => {
  const dataCenters = ref<Record<string, string>>({})
  const isLoading = ref(false)
  const hasFetched = ref(false)

  async function fetchDataCenters() {
    if (hasFetched.value || isLoading.value) {
      return
    }

    isLoading.value = true
    try {
      const response = await axios.get<Record<string, string>>(
        'https://cdn.jsdelivr.net/gh/LufsX/Cloudflare-Data-Center-IATA-Code-list/cloudflare-iata.json',
      )
      dataCenters.value = response.data
      hasFetched.value = true
    } catch (error) {
      console.error('Failed to fetch Cloudflare data centers:', error)
      // Optionally handle the error, e.g., show a notification
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