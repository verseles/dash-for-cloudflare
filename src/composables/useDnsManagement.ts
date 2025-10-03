import { ref, watch, nextTick } from 'vue';
import { useSettings } from 'src/composables/useSettings';
import { useCloudflareApi } from 'src/composables/useCloudflareApi';
import { useLoadingStore } from 'src/stores/loading';
import type { DnsRecord, Zone } from 'src/types';

export function useDnsManagement() {
  const { settings } = useSettings();
  const { getZones, getDnsRecords, createDnsRecord, updateDnsRecord, deleteDnsRecord } = useCloudflareApi();
  const loadingStore = useLoadingStore();

  const zones = ref<Zone[]>([]);
  const records = ref<DnsRecord[]>([]);
  const selectedZoneId = ref<string | null>(null);
  const isLoadingZones = ref(false);
  const isLoadingRecords = ref(false);
  const operationError = ref<string | null>(null);

  // Track fetch requests to prevent race conditions
  let currentFetchId = 0;

  const fetchZones = async () => {
    isLoadingZones.value = true;
    loadingStore.startLoading('fetch-zones');
    operationError.value = null;
    zones.value = [];
    records.value = [];
    selectedZoneId.value = null;

    if (!settings.cloudflareApiToken || settings.cloudflareApiToken.length < 40) {
      operationError.value = 'A valid Cloudflare API Token is required.';
      isLoadingZones.value = false;
      loadingStore.stopLoading('fetch-zones');
      return;
    }

    try {
      const fetchedZones = await getZones();
      zones.value = fetchedZones;
      if (zones.value.length > 0 && zones.value[0]) {
        selectedZoneId.value = zones.value[0].id;
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        operationError.value = `Failed to fetch zones: ${error.message}`;
      } else {
        operationError.value = 'An unknown error occurred while fetching zones.';
      }
      zones.value = [];
    } finally {
      isLoadingZones.value = false;
      loadingStore.stopLoading('fetch-zones');
    }
  };

  const fetchRecords = async (zoneId: string) => {
    if (!zoneId) return;

    // Increment fetch ID to track this request
    const fetchId = ++currentFetchId;

    isLoadingRecords.value = true;
    loadingStore.startLoading(`fetch-records-${zoneId}`);
    operationError.value = null;

    // Clear records after a small delay to prevent DOM issues
    await nextTick();
    if (currentFetchId === fetchId) {
      records.value = [];
    }

    try {
      const fetchedRecords = await getDnsRecords(zoneId);

      // Only update if this is still the current request
      if (currentFetchId === fetchId) {
        records.value = fetchedRecords;
      }
    } catch (error: unknown) {
      // Only update error if this is still the current request
      if (currentFetchId === fetchId) {
        if (error instanceof Error) {
          operationError.value = `Failed to fetch DNS records: ${error.message}`;
        } else {
          operationError.value = 'An unknown error occurred while fetching DNS records.';
        }
        records.value = [];
      }
    } finally {
      // Only update loading state if this is still the current request
      if (currentFetchId === fetchId) {
        isLoadingRecords.value = false;
        loadingStore.stopLoading(`fetch-records-${zoneId}`);
      }
    }
  };

  watch(selectedZoneId, async (newZoneId) => {
    if (newZoneId) {
      await fetchRecords(newZoneId);
    } else {
      // Cancel any pending requests
      currentFetchId++;
      records.value = [];
      isLoadingRecords.value = false;
      loadingStore.clearAllLoading();
    }
  });

  // Watch for token changes to refetch zones
  watch(
    () => settings.cloudflareApiToken,
    (newToken) => {
      if (newToken && newToken.length >= 40) {
        void fetchZones();
      } else {
        zones.value = [];
        records.value = [];
        selectedZoneId.value = null;
        operationError.value = null; // Clear error when token is cleared
        if (newToken) {
          // Only show length error if there's an invalid token
          operationError.value = 'The API token must be at least 40 characters long.';
        }
      }
    },
    { immediate: true },
  );

  const saveRecord = async (record: DnsRecord | Partial<DnsRecord>): Promise<boolean> => {
    if (!selectedZoneId.value) {
      operationError.value = 'No zone selected';
      return false;
    }

    operationError.value = null;
    try {
      // Determine if this is a create or update operation
      const isNewRecord = !record.id || record.id === '';
      
      let savedRecord: DnsRecord;
      
      if (isNewRecord) {
        // Create new record using POST
        savedRecord = await createDnsRecord(selectedZoneId.value, record);
        // Add the new record to the top of the list for better visibility
        records.value.unshift(savedRecord);
      } else {
        // Update existing record using PUT
        savedRecord = await updateDnsRecord(selectedZoneId.value, record as DnsRecord);
        // Find and update the record in the local state for reactivity
        const recordIndex = records.value.findIndex((r) => r.id === record.id);
        if (recordIndex !== -1) {
          records.value[recordIndex] = savedRecord;
        }
      }
      
      return true;
    } catch (error: unknown) {
      if (error instanceof Error) {
        operationError.value = `Failed to save record: ${error.message}`;
      } else {
        operationError.value = 'An unknown error occurred while saving record.';
      }
      return false;
    }
  };

  const deleteRecord = async (record: DnsRecord): Promise<boolean> => {
    if (!selectedZoneId.value) {
      operationError.value = 'No zone selected';
      return false;
    }

    operationError.value = null;
    try {
      // Call real Cloudflare API to delete the record
      await deleteDnsRecord(selectedZoneId.value, record.id);

      // Find and remove the record from the local state
      const recordIndex = records.value.findIndex((r) => r.id === record.id);
      if (recordIndex !== -1) {
        records.value.splice(recordIndex, 1);
      }
      return true;
    } catch (error: unknown) {
      if (error instanceof Error) {
        operationError.value = `Failed to delete record: ${error.message}`;
      } else {
        operationError.value = 'An unknown error occurred while deleting record.';
      }
      return false;
    }
  };

  return {
    zones,
    records,
    selectedZoneId,
    isLoadingZones,
    isLoadingRecords,
    operationError,
    fetchZones,
    saveRecord,
    deleteRecord,
  };
}
