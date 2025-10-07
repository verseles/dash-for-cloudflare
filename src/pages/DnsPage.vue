<template>
  <q-page>
    <!-- DNS Controls Section -->
    <div class="sticky-top bg-toolbar">
      <q-toolbar>
        <q-select v-model="selectedZoneId" :label="t('dns.zoneSelector')" :placeholder="t('dns.loadingZones')"
          :options="zones" option-value="id" option-label="name" emit-value map-options :loading="isLoadingZones"
          :disable="isLoadingZones || !!operationError" @update:model-value="onZoneChange" class="full-width"
          borderless />
      </q-toolbar>
      <!-- Filter chips toolbar -->
      <q-toolbar v-if="availableTypes.length > 0" class="filter-toolbar">
        <div class="full-width scroll no-wrap q-gutter-x-sm">
          <q-chip :outline="activeFilter !== 'All'" clickable @click="setFilter('All')"
            :color="activeFilter === 'All' ? 'primary' : 'grey-7'"
            :text-color="activeFilter === 'All' ? 'white' : undefined">
            {{ t('dns.filterAll') }}
          </q-chip>
          <q-chip v-for="type in availableTypes" :key="type" clickable :outline="activeFilter !== type"
            @click="setFilter(type)" :color="activeFilter === type ? 'primary' : 'grey-7'"
            :text-color="activeFilter === type ? 'white' : undefined">
            {{ type }}
          </q-chip>
        </div>
      </q-toolbar>
    </div>

    <q-tab-panels v-model="tab" animated class="bg-transparent">
      <q-tab-panel name="records" class="q-pa-none">
        <div class="dns-content" :key="selectedZoneId || 'no-zone'" style="padding-bottom: 64px">
          <div v-if="isLoadingRecords">
            <q-list class="q-px-md">
              <q-item v-for="n in 5" :key="`skeleton-${n}`" class="q-py-sm">
                <q-item-section>
                  <q-item-label>
                    <q-skeleton type="text" style="width: 40%" />
                  </q-item-label>
                  <q-item-label caption>
                    <q-skeleton type="text" style="width: 70%" />
                  </q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </div>
          <div v-else-if="filteredRecords.length === 0 && selectedZoneId && !isLoadingRecords" class="q-pa-md">
            <q-card flat bordered class="q-mt-md">
              <q-card-section>
                <div class="text-h6">{{ noRecordsMessage }}</div>
              </q-card-section>
            </q-card>
          </div>
          <q-list v-else-if="filteredRecords.length > 0 && !isLoadingRecords">
            <DnsRecordItem v-for="record in filteredRecords" :key="`${selectedZoneId}-${record.id}`" :record="record"
              :is-saving="savingRecordIds.has(record.id)" :is-new-record="newRecordIds.has(record.id)"
              :is-deleting="deletingRecordIds.has(record.id)" :zone-name="currentZoneName" @save="handleSave"
              @delete="handleDelete" @edit="handleEdit" />
          </q-list>
        </div>
      </q-tab-panel>
      <q-tab-panel name="analytics">
        <div class="q-pa-md">
          <div class="text-h6">{{ t('dns.analytics.title') }}</div>
          <p>{{ t('dns.analytics.placeholder') }}</p>
        </div>
      </q-tab-panel>
      <q-tab-panel name="settings">
        <div class="q-pa-md">
          <div class="text-h6">{{ t('dns.settings.title') }}</div>
          <p>{{ t('dns.settings.placeholder') }}</p>
        </div>
      </q-tab-panel>
    </q-tab-panels>

    <!-- FAB to add new DNS record -->
    <q-page-sticky v-if="tab === 'records'" position="bottom-right" :offset="[18, 100]">
      <q-btn fab icon="add" color="primary" :disable="!selectedZoneId || isLoadingZones" @click="handleAdd">
        <q-tooltip v-if="!selectedZoneId">{{ t('dns.selectZoneFirst') }}</q-tooltip>
      </q-btn>
    </q-page-sticky>

    <q-page-sticky expand position="bottom">
      <q-tabs v-model="tab" class="bg-primary text-white shadow-2 full-width" align="justify">
        <q-tab name="records" icon="list" :label="t('dns.tabs.records')" />
        <q-tab name="analytics" icon="analytics" :label="t('dns.tabs.analytics')" />
        <q-tab name="settings" icon="settings" :label="t('dns.tabs.settings')" />
      </q-tabs>
    </q-page-sticky>
  </q-page>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useQuasar } from 'quasar'
import DnsRecordItem from 'src/components/DnsRecordItem.vue'
import DnsRecordEditModal from 'src/components/DnsRecordEditModal.vue'
import { useDnsManagement } from 'src/composables/useDnsManagement'
import { useI18n } from 'src/composables/useI18n'
import { useLoadingStore } from 'src/stores/loading'
import type { DnsRecord } from 'src/types'

const $q = useQuasar()
const loadingStore = useLoadingStore()
const {
  zones,
  records,
  selectedZoneId,
  isLoadingZones,
  isLoadingRecords,
  fetchZones,
  saveRecord,
  deleteRecord,
  operationError,
} = useDnsManagement()

const { t } = useI18n()

const tab = ref('records')
const savingRecordIds = ref(new Set<string>())
const newRecordIds = ref(new Set<string>())
const deletingRecordIds = ref(new Set<string>())
const activeFilter = ref('All')

const availableTypes = computed(() => {
  if (!records.value) return []
  const types = new Set(records.value.map((record) => record.type))
  return Array.from(types).sort()
})

const filteredRecords = computed(() => {
  if (activeFilter.value === 'All') {
    return records.value
  }
  return records.value.filter((record) => record.type === activeFilter.value)
})

const noRecordsMessage = computed(() => {
  if (records.value.length === 0) {
    return t('dns.noRecords')
  }
  if (filteredRecords.value.length === 0) {
    return t('dns.noRecordsForFilter')
  }
  return ''
})

const currentZoneName = computed(() => {
  const zone = zones.value.find((z) => z.id === selectedZoneId.value)
  return zone?.name || ''
})

const setFilter = (type: string) => {
  activeFilter.value = type
}

watch(selectedZoneId, () => {
  activeFilter.value = 'All'
})

onMounted(() => {
  void fetchZones()
})

const onZoneChange = () => {
  // Zone change is clear from the UI, no notification needed
}

const handleSave = async (record: DnsRecord | Partial<DnsRecord>) => {
  const isNewRecord = !record.id || record.id === ''
  const operationId = `save-${record.id || 'new'}`

  if (record.id) {
    savingRecordIds.value.add(record.id)
  }
  loadingStore.startLoading(operationId)

  try {
    const success = await saveRecord(record)
    if (success && isNewRecord) {
      // Mark the new record for highlight animation
      // We need to find it in the records array (it's now at the top)
      const newRecord = records.value[0]
      if (newRecord) {
        newRecordIds.value.add(newRecord.id)
        // Remove highlight after animation completes
        setTimeout(() => {
          newRecordIds.value.delete(newRecord.id)
        }, 2500)
      }
    } else if (!success) {
      $q.notify({
        message: t('dns.toasts.errorSaving', {
          error: operationError.value,
        }),
        color: 'negative',
        position: 'top',
      })
    }
  } finally {
    if (record.id) {
      savingRecordIds.value.delete(record.id)
    }
    loadingStore.stopLoading(operationId)
  }
}

const handleDelete = (record: DnsRecord) => {
  // Show confirmation dialog
  $q.dialog({
    title: t('dns.confirmDelete.title'),
    message: t('dns.confirmDelete.message', { recordName: record.name, recordType: record.type }),
    cancel: {
      flat: true,
      label: t('common.cancel'),
    },
    ok: {
      label: t('dns.delete'),
      color: 'negative',
    },
    persistent: true,
  }).onOk(() => {
    const operationId = `delete-${record.id}`

    // Add deleting animation
    deletingRecordIds.value.add(record.id)

    // Wait for animation to play, then delete
    void new Promise<void>((resolve) => setTimeout(resolve, 1200)).then(async () => {
      loadingStore.startLoading(operationId)

      try {
        const success = await deleteRecord(record)
        $q.notify({
          message: success
            ? t('dns.toasts.recordDeleted', {
              recordName: record.name,
            })
            : t('dns.toasts.errorDeleting', {
              error: operationError.value,
            }),
          color: success ? 'dark' : 'negative',
          position: 'top',
        })
      } finally {
        deletingRecordIds.value.delete(record.id)
        loadingStore.stopLoading(operationId)
      }
    })
  })
}

const handleEdit = (record: DnsRecord) => {
  $q.dialog({
    component: DnsRecordEditModal,
    componentProps: {
      record,
      zoneName: currentZoneName.value,
    },
  }).onOk((updatedRecordData: Partial<DnsRecord>) => {
    const recordToSave = { ...record, ...updatedRecordData }
    void handleSave(recordToSave)
  })
}

const handleAdd = () => {
  if (!selectedZoneId.value) {
    $q.notify({
      message: t('dns.selectZoneFirst'),
      color: 'warning',
      position: 'top',
    })
    return
  }

  $q.dialog({
    component: DnsRecordEditModal,
    componentProps: {
      zoneName: currentZoneName.value,
    },
  }).onOk((newRecordData: Partial<DnsRecord>) => {
    // Just pass the new record data; saveRecord will handle the creation
    void handleSave(newRecordData)
  })
}
</script>