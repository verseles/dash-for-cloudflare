import { ref, watch } from 'vue';
import { useQuasar } from 'quasar';
import { storeToRefs } from 'pinia';
import { useSettings } from 'src/composables/useSettings';
import { useZoneStore } from 'src/stores/zoneStore';
import { useLoadingStore } from 'src/stores/loading';

interface AnalyticsData {
  total: { count: number }[];
  topQueryNames: { count: number; dimensions: { queryName: string } }[];
  topQueryTypes: { count: number; dimensions: { queryType: string } }[];
  topResponseCodes: { count: number; dimensions: { responseCode: string } }[];
}

export function useDnsAnalytics() {
  const $q = useQuasar();
  const { settings } = useSettings();
  const zoneStore = useZoneStore();
  const { selectedZoneId } = storeToRefs(zoneStore);
  const loadingStore = useLoadingStore();

  const cors_webproxy = 'https://cors.verseles.com';
  const apiBaseUrl = 'https://api.cloudflare.com/client/v4';
  const baseUrl = $q.platform.is.nativeMobile
    ? apiBaseUrl
    : `${cors_webproxy}/${apiBaseUrl.replace('https://', '')}`;

  const analyticsData = ref<AnalyticsData | null>(null);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  const cfGraphQLFetch = async <T>(query: string, variables: Record<string, unknown> = {}): Promise<T> => {
    if (!settings.cloudflareApiToken) {
      throw new Error('Cloudflare API token is not set.');
    }

    const response = await fetch(`${baseUrl}/graphql`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${settings.cloudflareApiToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query, variables }),
    });

    const responseBody = await response.json().catch(() => ({}));

    if (!response.ok) {
      const errorMessage =
        (responseBody.errors && responseBody.errors[0]?.message) || `HTTP error! status: ${response.status}`;
      throw new Error(errorMessage);
    }

    if (responseBody.errors && responseBody.errors.length > 0) {
      throw new Error(responseBody.errors[0]?.message || 'Cloudflare GraphQL API request failed.');
    }

    return responseBody.data;
  };


  const fetchAnalytics = async (since: Date, until: Date) => {
    if (!selectedZoneId.value) {
      analyticsData.value = null;
      return;
    }

    isLoading.value = true;
    error.value = null;
    loadingStore.startLoading('fetch-dns-analytics');

    try {
      const query = `
        query GetDnsAnalytics($zoneTag: string!, $since: Date!, $until: Date!) {
          viewer {
            zones(filter: {zoneTag: $zoneTag}) {
              total: dnsAnalyticsAdaptiveGroups(limit: 1, filter: {date_geq: $since, date_leq: $until}) {
                count
              }
              topQueryNames: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {date_geq: $since, date_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  queryName
                }
              }
              topQueryTypes: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {date_geq: $since, date_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  queryType
                }
              }
              topResponseCodes: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {date_geq: $since, date_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  responseCode
                }
              }
            }
          }
        }
      `;
      const variables = {
        zoneTag: selectedZoneId.value,
        since: since.toISOString().split('T')[0],
        until: until.toISOString().split('T')[0]
      };

      const result = await cfGraphQLFetch<{ viewer: { zones: AnalyticsData[] } }>(query, variables);
      if (result.viewer.zones.length > 0 && result.viewer.zones[0]) {
        analyticsData.value = result.viewer.zones[0];
      } else {
        analyticsData.value = null;
      }
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'An error occurred';
      analyticsData.value = null;
    } finally {
      isLoading.value = false;
      loadingStore.stopLoading('fetch-dns-analytics');
    }
  };

  watch(selectedZoneId, () => {
    analyticsData.value = null;
  });

  return {
    analyticsData,
    isLoading,
    error,
    fetchAnalytics,
  };
}