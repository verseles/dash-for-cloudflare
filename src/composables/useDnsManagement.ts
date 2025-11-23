import { ref, watch, nextTick } from 'vue';
import { storeToRefs } from 'pinia';
import { useCloudflareApi } from 'src/composables/useCloudflareApi';
import { useLoadingStore } from 'src/stores/loading';
import { useZoneStore } from 'src/stores/zoneStore';
import type { DnsRecord } from 'src/types';

export function useDnsManagement() {
  const { getDnsRecords, createDnsRecord, updateDnsRecord, deleteDnsRecord } = useCloudflareApi();
  const loadingStore = useLoadingStore();
  const zoneStore = useZoneStore();
  const { selectedZoneId } = storeToRefs(zoneStore);

  const records = ref<DnsRecord[]>([]);
  const isLoadingRecords = ref(false);
  const operationError = ref<string | null>(null);

  let currentFetchId = 0;

  const fetchRecords = async (zoneId: string) => {
    if (!zoneId) return;

    const fetchId = ++currentFetchId;

    isLoadingRecords.value = true;
    loadingStore.startLoading(`fetch-records-${zoneId}`);
    operationError.value = null;

    await nextTick();
    if (currentFetchId === fetchId) {
      records.value = [];
    }

    try {
      const fetchedRecords = await getDnsRecords(zoneId);
      if (currentFetchId === fetchId) {
        records.value = fetchedRecords;
      }
    } catch (error: unknown) {
      if (currentFetchId === fetchId) {
        if (error instanceof Error) {
          operationError.value = `Failed to fetch DNS records: ${error.message}`;
        } else {
          operationError.value = 'An unknown error occurred while fetching DNS records.';
        }
        records.value = [];
      }
    } finally {
      if (currentFetchId === fetchId) {
        isLoadingRecords.value = false;
        loadingStore.stopLoading(`fetch-records-${zoneId}`);
      }
    }
  };

  watch(
    selectedZoneId,
    async (newZoneId) => {
      if (newZoneId) {
        await fetchRecords(newZoneId);
      } else {
        currentFetchId++;
        records.value = [];
        isLoadingRecords.value = false;
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
      const isNewRecord = !record.id || record.id === '';

      let savedRecord: DnsRecord;

      if (isNewRecord) {
        savedRecord = await createDnsRecord(selectedZoneId.value, record);
        records.value.unshift(savedRecord);
      } else {
        savedRecord = await updateDnsRecord(selectedZoneId.value, record as DnsRecord);
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
      await deleteDnsRecord(selectedZoneId.value, record.id);

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
    records,
    isLoadingRecords,
    operationError,
    saveRecord,
    deleteRecord,
  };
}
