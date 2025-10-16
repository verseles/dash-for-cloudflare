<template>
    <q-page>
        <!-- Filter chips toolbar -->
        <q-toolbar class="filter-toolbar sticky-top-inside-page bg-toolbar">
            <div class="row items-center full-width no-wrap q-gutter-x-xs">
                <!-- Filter Chips -->
                <div class="scroll no-wrap q-gutter-x-sm col">
                    <q-chip :outline="activeFilter !== 'All'" size="sm" class="q-ma-xs q-pa-sm" clickable
                        @click="setFilter('All')" :color="activeFilter === 'All' ? 'primary' : 'grey-7'"
                        :text-color="activeFilter === 'All' ? 'white' : undefined">
                        {{ t('dns.filterAll') }}
                    </q-chip>
                    <q-chip v-for="type in availableTypes" :key="type" size="sm" class="q-ma-xs q-pa-sm" clickable
                        :outline="activeFilter !== type" @click="setFilter(type)"
                        :color="activeFilter === type ? 'primary' : 'grey-7'"
                        :text-color="activeFilter === 'white' ? 'white' : undefined">
                        {{ type }}
                    </q-chip>
                </div>

                <!-- Search Input / Button -->
                <div class="q-ml-sm">
                    <q-input v-if="searchFocused" ref="searchInput" v-model="searchQuery" dense borderless autofocus
                        :placeholder="t('dns.searchPlaceholder')" clearable @blur="onSearchBlur">
                        <template #prepend>
                            <q-icon name="search" />
                        </template>
                    </q-input>
                    <q-btn v-else flat round dense icon="search" @click="focusSearch" />
                </div>
            </div>
        </q-toolbar>''

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

        <!-- Fixed FAB to add new DNS record -->
        <q-page-sticky position="bottom-right" :offset="[18, 80]">
            <q-btn fab icon="add" color="primary" :outline="true" :disable="!selectedZoneId || isLoadingZones"
                @click="handleAdd">
                <q-tooltip>{{ t('dns.editRecord.create') }}</q-tooltip>
            </q-btn>
        </q-page-sticky>
    </q-page>
</template>

<script setup lang="ts">
import { computed, ref, watch, nextTick } from 'vue'
import { useQuasar, QInput } from 'quasar'
import { storeToRefs } from 'pinia'
import DnsRecordItem from 'src/components/DnsRecordItem.vue'
import DnsRecordEditModal from 'src/components/DnsRecordEditModal.vue'
import { useDnsManagement } from 'src/composables/useDnsManagement'
import { useI18n } from 'src/composables/useI18n'
import { useZoneStore } from 'src/stores/zoneStore'
import type { DnsRecord } from 'src/types'

const $q = useQuasar()
const zoneStore = useZoneStore()
const { selectedZoneId, zones, isLoadingZones } = storeToRefs(zoneStore)

const {
    records,
    isLoadingRecords,
    saveRecord,
    deleteRecord,
} = useDnsManagement()

const { t } = useI18n()

const savingRecordIds = ref(new Set<string>())
const newRecordIds = ref(new Set<string>())
const deletingRecordIds = ref(new Set<string>())
const activeFilter = ref('All')
const searchQuery = ref('')
const searchFocused = ref(false)
const searchInput = ref<QInput | null>(null)


const searchedRecords = computed(() => {
    if (!searchQuery.value) {
        return records.value
    }
    const lowerCaseQuery = searchQuery.value.toLowerCase()
    return records.value.filter(
        (record) =>
            record.name.toLowerCase().includes(lowerCaseQuery) ||
            record.content.toLowerCase().includes(lowerCaseQuery)
    )
})

const availableTypes = computed(() => {
    const source = searchQuery.value ? searchedRecords.value : records.value
    if (!source) return []
    const types = new Set(source.map((record) => record.type))
    return Array.from(types).sort()
})

watch(availableTypes, (newTypes) => {
    if (!newTypes.includes(activeFilter.value) && activeFilter.value !== 'All') {
        activeFilter.value = 'All'
    }
})

const filteredRecords = computed(() => {
    if (activeFilter.value === 'All') {
        return searchedRecords.value
    }
    return searchedRecords.value.filter((record) => record.type === activeFilter.value)
})

const noRecordsMessage = computed(() => {
    if (records.value.length === 0) {
        return t('dns.noRecords')
    }
    if (filteredRecords.value.length === 0) {
        return t('dns.noRecordsMatch')
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

const focusSearch = async () => {
    searchFocused.value = true
    await nextTick()
    searchInput.value?.focus()
}

const onSearchBlur = () => {
    if (!searchQuery.value) {
        searchFocused.value = false
    }
}


watch(selectedZoneId, () => {
    activeFilter.value = 'All'
    searchQuery.value = ''
})

async function handleSave(record: DnsRecord) {
    if (!record.id) return

    savingRecordIds.value.add(record.id)

    try {
        await saveRecord(record)

        $q.notify({
            message: t('dns.toasts.recordSaved', { recordName: record.name }),
            color: 'positive',
            position: 'top',
            timeout: 2000,
        })
    } catch (e: unknown) {
        const message = e instanceof Error ? e.message : String(e)
        $q.notify({
            message: t('dns.toasts.errorSaving', { error: message }),
            color: 'negative',
            position: 'top',
            timeout: 3000,
        })
    } finally {
        savingRecordIds.value.delete(record.id)
    }
}

function handleDelete(record: DnsRecord) {
    if (!record.id) return

    deletingRecordIds.value.add(record.id)

    void Promise.resolve().then(() => {
        setTimeout(() => {
            void (async () => {
                try {
                    await deleteRecord(record)

                    $q.notify({
                        message: t('dns.toasts.recordDeleted', { recordName: record.name }),
                        color: 'positive',
                        position: 'top',
                        timeout: 2000,
                    })
                } catch (e: unknown) {
                    const message = e instanceof Error ? e.message : String(e)
                    $q.notify({
                        message: t('dns.toasts.errorDeleting', { error: message }),
                        color: 'negative',
                        position: 'top',
                        timeout: 3000,
                    })
                } finally {
                    deletingRecordIds.value.delete(record.id)
                }
            })()
        }, 1200)
    })
}

function handleEdit(record: DnsRecord) {
    $q.dialog({
        component: DnsRecordEditModal,
        componentProps: {
            record: { ...record },
            zoneName: currentZoneName.value,
        },
    }).onOk((formData: DnsRecord) => {
        void handleSave({ ...formData, id: record.id, zone_id: record.zone_id })
    })
}

function handleAdd() {
    $q.dialog({
        component: DnsRecordEditModal,
        componentProps: {
            zoneName: currentZoneName.value,
        },
    }).onOk((formData: DnsRecord) => {
        void (async () => {
            if (!selectedZoneId.value) return

            const newRecord: DnsRecord = {
                ...formData,
                zone_id: selectedZoneId.value,
                id: `temp-${Date.now()}`,
            }

            newRecordIds.value.add(newRecord.id)

            try {
                await saveRecord(newRecord)

                $q.notify({
                    message: t('dns.toasts.recordCreated', { recordName: newRecord.name }),
                    color: 'positive',
                    position: 'top',
                    timeout: 2000,
                })

                // Remove o ID temporário após a animação
                setTimeout(() => {
                    newRecordIds.value.delete(newRecord.id)
                }, 2000)
            } catch (e: unknown) {
                newRecordIds.value.delete(newRecord.id)
                const message = e instanceof Error ? e.message : String(e)
                $q.notify({
                    message: t('dns.toasts.errorCreating', { error: message }),
                    color: 'negative',
                    position: 'top',
                    timeout: 3000,
                })
            }
        })()
    })
}
</script>

<style scoped>
.filter-toolbar {
    border-bottom: 1px solid rgba(0, 0, 0, 0.12);
    padding-right: 16px;
}

.body--dark .filter-toolbar {
    border-bottom-color: rgba(255, 255, 255, 0.12);
}

.bg-toolbar {
    background-color: white;
}

.body--dark .bg-toolbar {
    background-color: #1e1e1e;
}

.sticky-top-inside-page {
    position: sticky;
    top: 0;
    z-index: 100;
}

.scroll {
    overflow-x: auto;
    scrollbar-width: thin;
    padding: 8px 0;
}

.scroll::-webkit-scrollbar {
    height: 4px;
}

.scroll::-webkit-scrollbar-track {
    background: transparent;
}

.scroll::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 2px;
}

.body--dark .scroll::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
}
</style>