import { defineStore } from 'pinia';
import { ref, watch } from 'vue';
import { useSettings } from 'src/composables/useSettings';
import { useCloudflareApi } from 'src/composables/useCloudflareApi';
import { useLoadingStore } from 'src/stores/loading';
import type { Zone } from 'src/types';
import { LocalStorage } from 'quasar';

const ZONE_STORAGE_KEY = 'dash_selected_zone_id';

export const useZoneStore = defineStore('zone', () => {
  const { settings } = useSettings();
  const { getZones } = useCloudflareApi();
  const loadingStore = useLoadingStore();

  const zones = ref<Zone[]>([]);
  const selectedZoneId = ref<string | null>(LocalStorage.getItem(ZONE_STORAGE_KEY) || null);
  const isLoadingZones = ref(false);
  const operationError = ref<string | null>(null);

  const fetchZones = async () => {
    isLoadingZones.value = true;
    loadingStore.startLoading('fetch-zones');
    operationError.value = null;
    zones.value = [];

    if (!settings.cloudflareApiToken || settings.cloudflareApiToken.length < 40) {
      operationError.value = 'A valid Cloudflare API Token is required.';
      isLoadingZones.value = false;
      loadingStore.stopLoading('fetch-zones');
      return;
    }

    try {
      const fetchedZones = await getZones();
      zones.value = fetchedZones;

      // If the stored selectedZoneId is not valid, or not present, select the first zone.
      const isValidSelection =
        selectedZoneId.value && fetchedZones.some((z) => z.id === selectedZoneId.value);
      if (!isValidSelection && fetchedZones.length > 0 && fetchedZones[0]) {
        selectedZoneId.value = fetchedZones[0].id;
      } else if (!isValidSelection) {
        selectedZoneId.value = null;
      }
    } catch (error: unknown) {
      if (error instanceof Error) {
        operationError.value = `Failed to fetch zones: ${error.message}`;
      } else {
        operationError.value = 'An unknown error occurred while fetching zones.';
      }
      zones.value = [];
      selectedZoneId.value = null;
    } finally {
      isLoadingZones.value = false;
      loadingStore.stopLoading('fetch-zones');
    }
  };

  // Persist selectedZoneId to LocalStorage
  watch(selectedZoneId, (newId) => {
    if (newId) {
      LocalStorage.set(ZONE_STORAGE_KEY, newId);
    } else {
      LocalStorage.remove(ZONE_STORAGE_KEY);
    }
  });

  // Re-fetch zones if the API token changes
  watch(
    () => settings.cloudflareApiToken,
    (newToken) => {
      if (newToken && newToken.length >= 40) {
        void fetchZones();
      } else {
        zones.value = [];
        selectedZoneId.value = null;
        operationError.value = null;
      }
    },
    { immediate: true },
  );

  return {
    zones,
    selectedZoneId,
    isLoadingZones,
    operationError,
    fetchZones,
  };
});
