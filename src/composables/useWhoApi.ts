import { useSettings } from 'src/composables/useSettings'
import { useQuasar } from 'quasar'

interface WhoApiResponse {
  status: string
  status_desc: string
  taken: string
}

export function useWhoApi() {
  const { settings } = useSettings()
  const $q = useQuasar()

  const apiBaseUrl = 'https://api.whoapi.com'

  // Conditionally set the base URL based on the platform
  const baseUrl = $q.platform.is.nativeMobile
    ? apiBaseUrl
    : `https://cors.verseles.com/${apiBaseUrl.replace('https://', '')}`

  const whoApiFetch = async <T>(
    endpoint: string,
    options: RequestInit = {},
  ): Promise<T> => {
    if (!settings.whoApiKey) {
      throw new Error('WhoAPI key is not set.')
    }

    const response = await fetch(`${baseUrl}${endpoint}`, {
      ...options,
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({})) // Catch JSON parsing errors
      const errorMessage =
        errorData.errors?.[0]?.message ||
        `HTTP error! status: ${response.status}`
      throw new Error(errorMessage)
    }

    return response.json()
  }

  const checkDomainAvailability = async (domain: string): Promise<boolean> => {
    const response = await whoApiFetch<WhoApiResponse>(`?domain=${domain}&r=taken&apikey=${settings.whoApiKey}`)
    return response.taken === '0'
  }

  return {
    checkDomainAvailability,
  }
}