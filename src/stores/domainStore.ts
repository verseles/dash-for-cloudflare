import { defineStore } from 'pinia'
import { ref, watch } from 'vue'
import { useSettings } from 'src/composables/useSettings'
import { useCloudflareApi } from 'src/composables/useCloudflareApi'
import { useLoadingStore } from 'src/stores/loading'
import type { Domain } from 'src/types'

export const useDomainStore = defineStore('domain', () => {
    const { settings } = useSettings()
    const { getDomains } = useCloudflareApi()
    const loadingStore = useLoadingStore()

    const domains = ref<Domain[]>([])
    const isLoadingDomains = ref(false)
    const operationError = ref<string | null>(null)

    const fetchDomains = async () => {
        isLoadingDomains.value = true
        loadingStore.startLoading('fetch-domains')
        operationError.value = null
        domains.value = []

        if (!settings.cloudflareApiToken || settings.cloudflareApiToken.length < 40) {
            operationError.value = 'A valid Cloudflare API Token is required.'
            isLoadingDomains.value = false
            loadingStore.stopLoading('fetch-domains')
            return
        }

        if (!settings.cloudflareAccountId) {
            operationError.value = 'A valid Cloudflare Account ID is required.'
            isLoadingDomains.value = false
            loadingStore.stopLoading('fetch-domains')
            return
        }

        try {
            const fetchedDomains = await getDomains()
            domains.value = fetchedDomains
        } catch (error: unknown) {
            if (error instanceof Error) {
                operationError.value = `Failed to fetch domains: ${error.message}`
            } else {
                operationError.value = 'An unknown error occurred while fetching domains.'
            }
            domains.value = []
        } finally {
            isLoadingDomains.value = false
            loadingStore.stopLoading('fetch-domains')
        }
    }

    // Re-fetch domains if the API token or Account ID changes
    watch(
        () => [settings.cloudflareApiToken, settings.cloudflareAccountId],
        ([newToken, newAccountId]) => {
            if (newToken && newToken.length >= 40 && newAccountId) {
                void fetchDomains()
            } else {
                domains.value = []
                operationError.value = null
            }
        },
        { immediate: true },
    )

    return {
        domains,
        isLoadingDomains,
        operationError,
        fetchDomains,
    }
})