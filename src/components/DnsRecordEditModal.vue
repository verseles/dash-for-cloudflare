<template>
  <q-dialog ref="dialogRef" @hide="onDialogHide">
    <q-card class="q-dialog-plugin">
      <q-bar>
        <div>{{ t('dns.editRecord.title') }}</div>
        <q-space />
        <q-btn dense flat icon="close" @click="onDialogCancel" />
      </q-bar>

      <q-form @submit.prevent="onOKClick">
        <q-card-section class="q-gutter-md">
          <!-- Record Type -->
          <q-select v-model="formData.type" :label="t('dns.editRecord.type')" :options="recordTypes"
            :disable="isExistingRecord" outlined dense />

          <!-- Record Name -->
          <q-input v-model="formData.name" :label="t('dns.editRecord.name')"
            :placeholder="t('dns.editRecord.namePlaceholder')" type="text" required outlined dense />

          <!-- Record Content -->
          <q-input v-model="formData.content" :label="t('dns.editRecord.content')" :placeholder="getContentPlaceholder"
            :type="contentRows > 1 ? 'textarea' : 'text'" :rows="contentRows" required outlined dense autogrow />

          <!-- TTL -->
          <q-select v-model="formData.ttl" :label="t('dns.editRecord.ttl')" :options="ttlOptions" emit-value map-options
            outlined dense />

          <!-- Proxy Toggle (only for supported types) -->
          <div v-if="supportsProxy" class="row items-center justify-between">
            <div>
              {{ t('dns.editRecord.proxied') }}
              <q-icon name="help_outline" size="xs" color="grey-7" class="q-ml-xs cursor-pointer">
                <q-tooltip max-width="250px" anchor="top middle" self="bottom middle">
                  {{ t('dns.editRecord.proxiedDescription') }}
                </q-tooltip>
              </q-icon>
            </div>
            <CloudflareProxyToggle v-model="formData.proxied" />
          </div>
        </q-card-section>

        <!-- Action Buttons -->
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat :label="t('common.cancel')" @click="onDialogCancel" />
          <q-btn type="submit" :label="saveButtonText" color="primary" :disable="!isFormValid" />
        </q-card-actions>
      </q-form>
    </q-card>
  </q-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useDialogPluginComponent } from 'quasar'
import type { DnsRecord } from 'src/types'
import { useI18n } from 'src/composables/useI18n'
import CloudflareProxyToggle from './CloudflareProxyToggle.vue';

interface Props {
  record?: DnsRecord
  zoneName?: string
}
const props = defineProps<Props>()

defineEmits([...useDialogPluginComponent.emits])

const { dialogRef, onDialogHide, onDialogOK, onDialogCancel } =
  useDialogPluginComponent()
const { t } = useI18n()

interface DnsRecordForm {
  type: string
  name: string
  content: string
  ttl: number
  proxied: boolean
  id: string | undefined
}

// Initialize formData directly from props to avoid lifecycle issues.
const formData = ref<DnsRecordForm>({
  type: props.record?.type || 'A',
  name: props.record?.name || '',
  content: props.record?.content || '',
  ttl: props.record?.ttl || 1,
  proxied: props.record?.proxied ?? false,
  id: props.record?.id,
})


const isExistingRecord = computed(() => !!props.record?.id)
const supportsProxy = computed(() => {
  return ['A', 'AAAA', 'CNAME'].includes(formData.value.type || '')
})
const contentRows = computed(() => (formData.value.type === 'TXT' ? 3 : 1))

const getContentPlaceholder = computed(() => {
  const type = formData.value.type
  const placeholders: Record<string, string> = {
    A: '192.168.1.1',
    AAAA: '2001:db8::1',
    CNAME: 'example.com',
    TXT: '"v=spf1 include:_spf.google.com ~all"',
    MX: 'mail.example.com',
    SRV: '10 5 443 target.example.com',
    NS: 'ns1.example.com',
    PTR: 'example.com',
  }
  return placeholders[type || 'A'] || ''
})

const isFormValid = computed(() => {
  return !!(formData.value.name && formData.value.content)
})

const saveButtonText = computed(() => {
  return isExistingRecord.value
    ? t('dns.editRecord.update')
    : t('dns.editRecord.create')
})

watch(
  () => formData.value.type,
  (newType) => {
    if (!['A', 'AAAA', 'CNAME'].includes(newType || '')) {
      formData.value.proxied = false
    }
  },
)


function onOKClick() {
  if (!isFormValid.value) return
  onDialogOK(formData.value)
}

const recordTypes = [
  'A',
  'AAAA',
  'CNAME',
  'TXT',
  'MX',
  'SRV',
  'NS',
  'PTR',
]
const ttlOptions = [
  { label: 'Auto', value: 1 },
  { label: '2 minutes', value: 120 },
  { label: '5 minutes', value: 300 },
  { label: '10 minutes', value: 600 },
  { label: '15 minutes', value: 900 },
  { label: '30 minutes', value: 1800 },
  { label: '1 hour', value: 3600 },
  { label: '2 hours', value: 7200 },
  { label: '5 hours', value: 18000 },
  { label: '12 hours', value: 43200 },
  { label: '1 day', value: 86400 },
]
</script>

<style scoped>
.q-dialog-plugin {
  width: 500px;
  max-width: 90vw;
}
</style>