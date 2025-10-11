<template>
  <q-dialog ref="dialogRef" @hide="onDialogHide" persistent>
    <q-card class="q-dialog-plugin">
      <q-bar>
        <div>{{ t('dns.settingsPage.dnssecDetailsModal.title') }}</div>
        <q-space />
        <q-btn v-close-popup dense flat icon="close" @click="onDialogCancel" />
      </q-bar>

      <q-card-section>
        <p>{{ t('dns.settingsPage.dnssecDetailsModal.description') }}</p>
      </q-card-section>

      <q-card-section class="q-gutter-y-md">
        <div v-for="field in fields" :key="field.key" @click="copy(field.value, field.label)">
          <q-input :model-value="String(field.value || '')" :label="field.label" filled readonly type="textarea"
            autogrow rows="1" class="cursor-pointer">
            <template #append>
              <q-icon name="content_copy" size="xs" />
            </template>
          </q-input>
          <q-tooltip anchor="center right" self="center left" :offset="[10, 10]">
            {{ t('dns.settingsPage.dnssecDetailsModal.copyToClipboard') }}
          </q-tooltip>
        </div>
      </q-card-section>

      <q-card-actions align="right" class="q-pa-md">
        <q-btn color="primary" :label="t('common.ok')" @click="onDialogOK" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useDialogPluginComponent, useQuasar, copyToClipboard } from 'quasar'
import type { DnssecDetails } from 'src/types'
import { useI18n } from 'src/composables/useI18n'

interface Props {
  dnssecDetails: DnssecDetails
}
const props = defineProps<Props>()

defineEmits([...useDialogPluginComponent.emits])

const { dialogRef, onDialogHide, onDialogOK, onDialogCancel } = useDialogPluginComponent()
const { t } = useI18n()
const $q = useQuasar()

const fields = computed(() => [
  { key: 'ds', label: t('dns.settingsPage.dnssecDetailsModal.dsRecord'), value: props.dnssecDetails.ds },
  { key: 'digest', label: t('dns.settingsPage.dnssecDetailsModal.digest'), value: props.dnssecDetails.digest },
  { key: 'digest_type', label: t('dns.settingsPage.dnssecDetailsModal.digestType'), value: props.dnssecDetails.digest_type },
  { key: 'algorithm', label: t('dns.settingsPage.dnssecDetailsModal.algorithm'), value: props.dnssecDetails.algorithm },
  { key: 'public_key', label: t('dns.settingsPage.dnssecDetailsModal.publicKey'), value: props.dnssecDetails.public_key },
  { key: 'key_tag', label: t('dns.settingsPage.dnssecDetailsModal.keyTag'), value: props.dnssecDetails.key_tag },
  { key: 'flags', label: t('dns.settingsPage.dnssecDetailsModal.flags'), value: props.dnssecDetails.flags },
])

const copy = async (text: string | number | null | undefined, label: string) => {
  if (!text) return
  try {
    await copyToClipboard(String(text))
    $q.notify({
      message: t('dns.settingsPage.toasts.copied', { field: label }),
      color: 'positive',
      position: 'top',
      timeout: 2000,
    })
  } catch {
    $q.notify({
      message: t('dns.settingsPage.toasts.copyError'),
      color: 'negative',
      position: 'top',
      timeout: 2000,
    })
  }
}
</script>

<style scoped>
.q-dialog-plugin {
  width: 600px;
  max-width: 90vw;
}
</style>