<template>
  <q-page padding>
    <div v-if="isLoading" class="flex flex-center" style="height: 50vh">
      <q-spinner-dots color="primary" size="40px" />
    </div>
    <div v-else class="q-mx-auto" style="max-width: 1024px">
      <!-- Header Section -->
      <div class="q-mb-lg">
        <div class="text-overline text-grey-8">DNS</div>
        <div class="text-h4 q-mt-xs q-mb-sm">{{ t('dns.settingsPage.title') }}</div>
        <div class="row items-center">
          <span class="text-body1 text-grey-8 q-mr-sm">{{ t('dns.settingsPage.subtitle') }}</span>
          <a href="#" class="text-primary row items-center no-wrap" style="text-decoration: none; font-weight: 500">
            <span>{{ t('dns.settingsPage.docsLink') }}</span>
            <q-icon name="open_in_new" size="xs" class="q-ml-xs" />
          </a>
        </div>
      </div>

      <!-- DNSSEC Card -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isSaving" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.dnssecCard.description') }}
            </p>
            <div class="row items-center text-caption q-mt-sm q-pa-sm rounded-borders"
              :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-2'">
              <q-icon name="info_outline" class="q-mr-xs" :color="$q.dark.isActive ? 'grey-5' : 'grey-7'" />
              <span :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
                {{ t('dns.settingsPage.dnssecCard.pending') }}
              </span>
            </div>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn flat color="primary" :label="t('dns.settingsPage.dnssecCard.cancelBtn')" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="left" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" :label="t('dns.settingsPage.dnssecCard.dsRecordBtn')"
            icon-right="arrow_forward" />
          <q-btn flat dense no-caps color="primary" :label="t('dns.settingsPage.help')" icon-right="open_in_new"
            class="q-ml-md" />
        </q-card-actions>
      </q-card>

      <!-- Multi-signer DNSSEC -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isSaving" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.multiSigner.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.multiSigner.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle :model-value="multiSignerDnssec" :disable="isSaving || isLoading"
              @update:model-value="(val) => updateSetting('multiSignerDnssec', val)" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" :label="t('dns.settingsPage.help')" icon-right="open_in_new" />
        </q-card-actions>
      </q-card>

      <!-- Multi-provider DNS -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isSaving" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.multiProvider.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              <span v-html="t('dns.settingsPage.multiProvider.description')" />
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle :model-value="multiProviderDns" :disable="isSaving || isLoading"
              @update:model-value="(val) => updateSetting('multiProviderDns', val)" />
          </div>
        </q-card-section>
      </q-card>

      <!-- CNAME flattening for all CNAME records -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isSaving" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.cnameFlattening.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.cnameFlattening.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle :model-value="cnameFlattening" :disable="isSaving || isLoading"
              @update:model-value="(val) => updateSetting('cnameFlattening', val)" />
          </div>
        </q-card-section>
      </q-card>

      <!-- Email Security -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isSaving" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.emailSecurity.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.emailSecurity.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn color="primary" :label="t('dns.settingsPage.emailSecurity.configureBtn')" @click="showWorkInProgress" />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn flat dense no-caps color="primary" :label="t('dns.settingsPage.help')" icon-right="open_in_new" />
        </q-card-actions>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useI18n } from 'src/composables/useI18n'
import { useQuasar } from 'quasar'
import { useZoneStore } from 'src/stores/zoneStore'
import { storeToRefs } from 'pinia'
import { useCloudflareApi } from 'src/composables/useCloudflareApi'
import type { DnsSetting } from 'src/types'

type SettingsMap = {
  [key: string]: DnsSetting | undefined;
}

const { t } = useI18n()
const $q = useQuasar()
const zoneStore = useZoneStore()
const { selectedZoneId } = storeToRefs(zoneStore)
const { getDnsSettings, updateDnsSetting, getDnssec, updateDnssec } = useCloudflareApi()

const isLoading = ref(true)
const isSaving = ref(false)

const multiSignerDnssec = ref(false)
const multiProviderDns = ref(false)
const cnameFlattening = ref(false)

const fetchSettings = async () => {
  if (!selectedZoneId.value) return

  isLoading.value = true
  try {
    const [settingsResult, dnssecResult] = await Promise.all([
      getDnsSettings(selectedZoneId.value),
      getDnssec(selectedZoneId.value),
    ])

    const settingsMap: SettingsMap = settingsResult.reduce((acc: SettingsMap, setting: DnsSetting) => {
      acc[setting.id] = setting
      return acc
    }, {})

    cnameFlattening.value = settingsMap.cname_flattening?.value === 'flatten_all'
    // The multi_provider setting is not officially documented for this endpoint.
    // We assume it exists and is a boolean. If not found, the toggle will just be off.
    multiProviderDns.value = !!settingsMap.multi_provider?.value
    multiSignerDnssec.value = dnssecResult.multi_signer
  } catch (e: unknown) {
    const error = e instanceof Error ? e.message : String(e)
    $q.notify({
      color: 'negative',
      message: t('dns.settingsPage.toasts.fetchError', { error }),
    })
  } finally {
    isLoading.value = false
  }
}

watch(selectedZoneId, fetchSettings, { immediate: true })

const updateSetting = async (key: 'cnameFlattening' | 'multiProviderDns' | 'multiSignerDnssec', value: boolean) => {
  if (!selectedZoneId.value) return

  isSaving.value = true
  const originalValues = {
    cnameFlattening: cnameFlattening.value,
    multiProviderDns: multiProviderDns.value,
    multiSignerDnssec: multiSignerDnssec.value,
  };

  // Optimistic UI update
  if (key === 'cnameFlattening') cnameFlattening.value = value
  if (key === 'multiProviderDns') multiProviderDns.value = value
  if (key === 'multiSignerDnssec') multiSignerDnssec.value = value

  try {
    let settingName = ''
    if (key === 'cnameFlattening') {
      settingName = t('dns.settingsPage.cnameFlattening.title')
      const apiValue = value ? 'flatten_all' : 'flatten_at_root'
      await updateDnsSetting(selectedZoneId.value, 'cname_flattening', apiValue)
    } else if (key === 'multiProviderDns') {
      settingName = t('dns.settingsPage.multiProvider.title')
      await updateDnsSetting(selectedZoneId.value, 'multi_provider', value)
    } else if (key === 'multiSignerDnssec') {
      settingName = t('dns.settingsPage.multiSigner.title')
      await updateDnssec(selectedZoneId.value, { multi_signer: value })
    }

    $q.notify({
      color: 'positive',
      message: t('dns.settingsPage.toasts.updateSuccess', { setting: settingName }),
    })
  } catch (e: unknown) {
    // Revert UI on error
    cnameFlattening.value = originalValues.cnameFlattening
    multiProviderDns.value = originalValues.multiProviderDns
    multiSignerDnssec.value = originalValues.multiSignerDnssec

    const error = e instanceof Error ? e.message : String(e)
    $q.notify({
      color: 'negative',
      message: t('dns.settingsPage.toasts.updateError', { setting: key, error }),
    })
  } finally {
    isSaving.value = false
  }
}

const showWorkInProgress = () => {
  $q.notify({
    message: t('common.workInProgress'),
    color: 'info',
    position: 'top'
  })
}
</script>

<style lang="scss" scoped>
.text-body2 a {
  text-decoration: none;
  font-weight: 500;
}
</style>