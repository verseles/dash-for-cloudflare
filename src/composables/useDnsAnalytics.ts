import { ref, watch } from 'vue';
import { useQuasar } from 'quasar';
import { storeToRefs } from 'pinia';
import { useSettings } from 'src/composables/useSettings';
import { useZoneStore } from 'src/stores/zoneStore';
import { useLoadingStore } from 'src/stores/loading';
import type { DnsAnalyticsData } from 'src/types';

// This interface matches the expected structure from the GraphQL query
interface AnalyticsResponse {
  viewer: {
    zones: DnsAnalyticsData[];
  };
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

  const analyticsData = ref<DnsAnalyticsData | null>(null);
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
        query GetDnsAnalytics($zoneTag: string!, $since: DateTime!, $until: DateTime!) {
          viewer {
            zones(filter: {zoneTag: $zoneTag}) {
              total: dnsAnalyticsAdaptiveGroups(limit: 1, filter: {datetime_geq: $since, datetime_leq: $until}) {
                count
              }
              timeSeries: dnsAnalyticsAdaptiveGroups(
                limit: 1000,
                filter: {datetime_geq: $since, datetime_leq: $until}
              ) {
                count
                dimensions {
                  ts: datetimeFifteenMinutes
                }
              }
              byQueryName: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  queryName
                }
              }
              byRecordType: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  queryType
                }
              }
              byResponseCode: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  responseCode
                }
              }
              byDataCenter: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  coloName
                }
              }
              byIpVersion: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  ipVersion
                }
              }
              byProtocol: dnsAnalyticsAdaptiveGroups(limit: 10, filter: {datetime_geq: $since, datetime_leq: $until}, orderBy: [count_DESC]) {
                count
                dimensions {
                  protocol
                }
              }
            }
          }
        }
      `;
      const variables = {
        zoneTag: selectedZoneId.value,
        since: since.toISOString(),
        until: until.toISOString()
      };

      const result = await cfGraphQLFetch<AnalyticsResponse>(query, variables);

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