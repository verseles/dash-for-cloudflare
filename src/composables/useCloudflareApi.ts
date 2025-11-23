import { useSettings } from 'src/composables/useSettings'
import type { DnsRecord, Zone, DnsSetting, DnssecDetails, DnsZoneSettings } from 'src/types'
import { useQuasar } from 'quasar'

// Define the structure of the Cloudflare API response
interface CloudflareResponse<T> {
  result: T
  success: boolean
  errors: { code: number; message: string }[]
  messages: string[]
}

export function useCloudflareApi() {
  const { settings } = useSettings()
  const $q = useQuasar()

  const cors_webproxy = 'https://cors.verseles.com'
  const apiBaseUrl = 'https://api.cloudflare.com/client/v4'

  // Conditionally set the base URL based on the platform
  const baseUrl = $q.platform.is.nativeMobile
    ? apiBaseUrl
    : `${cors_webproxy}/${apiBaseUrl.replace('https://', '')}`

  const cfFetch = async <T>(
    endpoint: string,
    options: RequestInit = {},
  ): Promise<T> => {
    if (!settings.cloudflareApiToken) {
      throw new Error('Cloudflare API token is not set.')
    }

    const response = await fetch(`${baseUrl}${endpoint}`, {
      ...options,
      headers: {
        ...options.headers,
        Authorization: `Bearer ${settings.cloudflareApiToken}`,
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({})) // Catch JSON parsing errors
      const errorMessage =
        errorData.errors?.[0]?.message ||
        `HTTP error! status: ${response.status}`
      throw new Error(errorMessage)
    }

    const data: CloudflareResponse<T> = await response.json()

    if (!data.success) {
      throw new Error(
        data.errors?.[0]?.message || 'Cloudflare API request failed.',
      )
    }

    return data.result
  }

  const getDnsSettings = async (zoneId: string): Promise<DnsSetting[]> => {
    return cfFetch<DnsSetting[]>(`/zones/${zoneId}/settings`)
  }

  const updateDnsSetting = async (
    zoneId: string,
    settingId: string,
    value: string | boolean | number
  ): Promise<DnsSetting> => {
    return cfFetch<DnsSetting>(`/zones/${zoneId}/settings/${settingId}`, {
      method: 'PATCH',
      body: JSON.stringify({ value }),
    })
  }

  const getDnsZoneSettings = async (zoneId: string): Promise<DnsZoneSettings> => {
    return cfFetch<DnsZoneSettings>(`/zones/${zoneId}/dns_settings`)
  }

  const updateDnsZoneSettings = async (
    zoneId: string,
    payload: Partial<DnsZoneSettings>
  ): Promise<DnsZoneSettings> => {
    return cfFetch<DnsZoneSettings>(`/zones/${zoneId}/dns_settings`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    })
  }

  const getDnssec = async (zoneId: string): Promise<DnssecDetails> => {
    return cfFetch<DnssecDetails>(`/zones/${zoneId}/dnssec`)
  }

  const updateDnssec = async (
    zoneId: string,
    data: { dnssec_multi_signer?: boolean; status?: string }
  ): Promise<DnssecDetails> => {
    return cfFetch<DnssecDetails>(`/zones/${zoneId}/dnssec`, {
      method: 'PATCH',
      body: JSON.stringify(data),
    })
  }

  const getZones = async (): Promise<Zone[]> => {
    return cfFetch<Zone[]>('/zones?per_page=100')
  }



  const getDnsRecords = async (zoneId: string): Promise<DnsRecord[]> => {
    return cfFetch<DnsRecord[]>(`/zones/${zoneId}/dns_records`)
  }

  const createDnsRecord = async (
    zoneId: string,
    record: Partial<DnsRecord>,
  ): Promise<DnsRecord> => {
    return cfFetch<DnsRecord>(`/zones/${zoneId}/dns_records`, {
      method: 'POST',
      body: JSON.stringify({
        type: record.type,
        name: record.name,
        content: record.content,
        ttl: record.ttl,
        proxied: record.proxied,
      }),
    })
  }

  const updateDnsRecord = async (
    zoneId: string,
    record: DnsRecord,
  ): Promise<DnsRecord> => {
    return cfFetch<DnsRecord>(`/zones/${zoneId}/dns_records/${record.id}`, {
      method: 'PUT',
      body: JSON.stringify({
        type: record.type,
        name: record.name,
        content: record.content,
        ttl: record.ttl,
        proxied: record.proxied,
      }),
    })
  }

  const deleteDnsRecord = async (
    zoneId: string,
    recordId: string,
  ): Promise<{ id: string }> => {
    return cfFetch<{ id: string }>(`/zones/${zoneId}/dns_records/${recordId}`, {
      method: 'DELETE',
    })
  }

  return {
    getZones,

    getDnsRecords,
    createDnsRecord,
    updateDnsRecord,
    deleteDnsRecord,
    getDnsSettings,
    updateDnsSetting,
    getDnssec,
    updateDnssec,
    getDnsZoneSettings,
    updateDnsZoneSettings,
  }
}