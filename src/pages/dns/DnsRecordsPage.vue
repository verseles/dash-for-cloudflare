<template>
    <q-page>
        <!-- Filter chips toolbar -->
        <q-toolbar v-if="availableTypes.length > 0" class="filter-toolbar sticky-top-inside-page bg-toolbar">
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
                <DnsRecordItem v-for="record in filteredRecords" :key="`${selectedZoneId}-${record.id}`"
                    :record="record" :is-saving="savingRecordIds.has(record.id)"
                    :is-new-record="newRecordIds.has(record.id)" :is-deleting="deletingRecordIds.has(record.id)"
                    :zone-name="currentZoneName" @save="handleSave" @delete="handleDelete" @edit="handleEdit" />
            </q-list>
        </div>

        <!-- FAB to add new DNS record -->
        <q-page-sticky position="bottom-right" :offset="fabPos">
            <q-fab icon="add" direction="up" color="primary" :disable="!selectedZoneId || isLoadingZones || draggingFab"
                v-touch-pan.prevent.mouse="moveFab">
                <q-fab-action @click="handleAdd" color="primary" icon="add" :disable="draggingFab">
                    <q-tooltip>{{ t('dns.editRecord.create') }}</q-tooltip>
                </q-fab-action>
            </q-fab>
        </q-page-sticky>
    </q-page>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useQuasar } from 'quasar'
import { storeToRefs } from 'pinia'
import DnsRecordItem from 'src/components/DnsRecordItem.vue'
import DnsRecordEditModal from 'src/components/DnsRecordEditModal.vue'
import { useDnsManagement } from 'src/composables/useDnsManagement'
import { useI18n } from 'src/composables/useI18n'
import { useLoadingStore } from 'src/stores/loading'
import { useZoneStore } from 'src/stores/zoneStore'
import type { DnsRecord } from 'src/types'

const $q = useQuasar()
const loadingStore = useLoadingStore()
const zoneStore = useZoneStore()
const { selectedZoneId, zones, isLoadingZones } = storeToRefs(zoneStore)

const {
    records,
    isLoadingRecords,
    saveRecord,
    deleteRecord,
    operationError,
} = useDnsManagement()

const { t } = useI18n()

const savingRecordIds = ref(new Set<string>())
const newRecordIds = ref(new Set<string>())
const deletingRecordIds = ref(new Set<string>())
const activeFilter = ref('All')

// Draggable FAB state
const fabPos = ref([18, 18])
const draggingFab = ref(false)

function moveFab(ev: { isFirst: boolean, isFinal: boolean, delta: { x: number, y: number } }) {
    draggingFab.value = ev.isFirst !== true && ev.isFinal !== true

    fabPos.value[0] -= ev.delta.x
    fabPos.value[1] -= ev.delta.y
}


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
            const newRecord = records.value[0]
            if (newRecord) {
                newRecordIds.value.add(newRecord.id)
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
        deletingRecordIds.value.add(record.id)

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
        void handleSave(newRecordData)
    })
}

</script>

<style lang="scss" scoped>
.filter-toolbar {

    // This ensures the toolbar with chips is always visible when scrolling the page content
    // and stays below the main q-toolbar
    .scroll {
        overflow-x: auto;
        width: 100%;
    }
}

.sticky-top-inside-page {
    position: sticky;
    top: 0; // Adjust if your main header has a different height
    z-index: 1;
}

// Add padding to the bottom of the page content to avoid being hidden by the sticky tabs
.dns-content {
    padding-bottom: 50px; // Height of the tabs bar
}
</style>