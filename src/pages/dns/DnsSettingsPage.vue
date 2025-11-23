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
          <a
            :href="dnsDocumentationLink"
            target="_blank"
            rel="noopener noreferrer"
            class="text-primary row items-center no-wrap"
            style="text-decoration: none; font-weight: 500"
          >
            <span>{{ t('dns.settingsPage.docsLink') }}</span>
            <q-icon name="open_in_new" size="xs" class="q-ml-xs" />
          </a>
        </div>
      </div>

      <!-- DNSSEC Card (Active State) -->
      <q-card v-if="dnssecStatus === 'active'" flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.dnssecStatus" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
            <div class="q-mt-sm">
              <div class="row items-center text-positive">
                <q-icon name="check_circle" class="q-mr-sm" />
                <span>{{
                  t('dns.settingsPage.dnssecCard.successMessage', { zoneName: currentZoneName })
                }}</span>
              </div>
              <div class="text-caption q-mt-sm">
                <strong>DS Record</strong><br />
                <code>{{ dnssecDetails?.ds }}</code>
              </div>
            </div>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn
              color="primary"
              :label="t('dns.settingsPage.dnssecCard.disableBtn')"
              @click="handleDisableDnssec"
            />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn
            flat
            dense
            no-caps
            color="primary"
            :label="t('dns.settingsPage.help')"
            icon-right="open_in_new"
            :href="dnssecHelpLink"
            target="_blank"
            rel="noopener noreferrer"
            type="a"
          />
        </q-card-actions>
      </q-card>

      <!-- DNSSEC Card (Pending State) -->
      <q-card v-if="dnssecStatus === 'pending'" flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.dnssecStatus" />

        <!-- Special state for Cloudflare Registrar -->
        <div v-if="isCloudflareRegistrar">
          <q-card-section class="row items-start justify-between">
            <div class="col-xs-12 col-md-9 q-pr-md">
              <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
              <p class="text-body2 text-grey-8 q-mt-sm">
                {{ t('dns.settingsPage.dnssecCard.enableDescription') }}
              </p>
              <div
                class="row items-center text-caption q-mt-sm q-pa-sm rounded-borders"
                :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-2'"
              >
                <q-icon
                  name="info_outline"
                  class="q-mr-xs"
                  :color="$q.dark.isActive ? 'grey-5' : 'grey-7'"
                />
                <span :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
                  {{ t('dns.settingsPage.dnssecCard.pendingWithCfRegistrar') }}
                </span>
              </div>
            </div>
            <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
              <q-btn
                flat
                color="primary"
                :label="t('dns.settingsPage.dnssecCard.cancelBtn')"
                @click="handleCancelDnssecSetup"
              />
            </div>
          </q-card-section>
          <q-separator />
          <q-card-actions align="right" class="q-pa-md">
            <q-btn
              flat
              dense
              no-caps
              color="primary"
              :label="t('dns.settingsPage.help')"
              icon-right="open_in_new"
              :href="dnssecHelpLink"
              target="_blank"
              rel="noopener noreferrer"
              type="a"
            />
          </q-card-actions>
        </div>

        <!-- Default pending state -->
        <div v-else>
          <q-card-section class="row items-start justify-between">
            <div class="col-xs-12 col-md-9 q-pr-md">
              <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
              <p class="text-body2 text-grey-8 q-mt-sm">
                {{ t('dns.settingsPage.dnssecCard.description') }}
              </p>
              <div
                class="row items-center text-caption q-mt-sm q-pa-sm rounded-borders"
                :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-2'"
              >
                <q-icon
                  name="info_outline"
                  class="q-mr-xs"
                  :color="$q.dark.isActive ? 'grey-5' : 'grey-7'"
                />
                <span :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
                  {{ t('dns.settingsPage.dnssecCard.pending') }}
                </span>
              </div>
            </div>
            <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
              <q-btn
                flat
                color="primary"
                :label="t('dns.settingsPage.dnssecCard.cancelBtn')"
                @click="handleCancelDnssecSetup"
              />
            </div>
          </q-card-section>
          <q-separator />
          <q-card-actions align="left" class="q-pa-md">
            <q-btn
              flat
              dense
              no-caps
              color="primary"
              :label="t('dns.settingsPage.dnssecCard.dsRecordBtn')"
              icon-right="arrow_forward"
              @click="showDnssecDetails"
            />
            <q-btn
              flat
              dense
              no-caps
              color="primary"
              :label="t('dns.settingsPage.help')"
              icon-right="open_in_new"
              class="q-ml-md"
              :href="dnssecHelpLink"
              target="_blank"
              rel="noopener noreferrer"
              type="a"
            />
          </q-card-actions>
        </div>
      </q-card>

      <!-- DNSSEC Card (Pending Deletion State) -->
      <q-card v-if="dnssecStatus === 'pending-disabled'" flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.dnssecStatus" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
            <div
              class="row items-center text-caption q-mt-sm q-pa-sm rounded-borders"
              :class="$q.dark.isActive ? 'bg-grey-9' : 'bg-grey-2'"
            >
              <q-icon
                name="info_outline"
                class="q-mr-xs"
                :color="$q.dark.isActive ? 'grey-5' : 'grey-7'"
              />
              <span :class="$q.dark.isActive ? 'text-grey-5' : 'text-grey-7'">
                {{ t('dns.settingsPage.dnssecCard.pendingDeletion') }}
              </span>
            </div>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn
              color="primary"
              :label="t('dns.settingsPage.dnssecCard.cancelDeletionBtn')"
              @click="handleCancelDnssecDeletion"
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- DNSSEC Card (Disabled State) -->
      <q-card v-if="dnssecStatus === 'disabled'" flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.dnssecStatus" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.dnssecCard.title') }}</div>
            <p v-if="isCloudflareRegistrar" class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.dnssecCard.enableDescriptionCF') }}
            </p>
            <p v-else class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.dnssecCard.enableDescription') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn
              color="primary"
              :label="t('dns.settingsPage.dnssecCard.enableBtn')"
              @click="handleEnableDnssec"
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- Multi-signer DNSSEC -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.multiSignerDnssec" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.multiSigner.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.multiSigner.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle
              :model-value="multiSignerDnssec"
              :disable="isAnythingSaving || isLoading"
              @update:model-value="(val) => updateSetting('multiSignerDnssec', val)"
            />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn
            flat
            dense
            no-caps
            color="primary"
            :label="t('dns.settingsPage.help')"
            icon-right="open_in_new"
            :href="dnssecHelpLink"
            target="_blank"
            rel="noopener noreferrer"
            type="a"
          />
        </q-card-actions>
      </q-card>

      <!-- Multi-provider DNS -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.multiProviderDns" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.multiProvider.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              <span v-html="t('dns.settingsPage.multiProvider.description')" />
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle
              :model-value="multiProviderDns"
              :disable="isAnythingSaving || isLoading"
              @update:model-value="(val) => updateSetting('multiProviderDns', val)"
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- CNAME flattening for all CNAME records -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="savingStates.cnameFlattening" />
        <q-card-section class="row items-center justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.cnameFlattening.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.cnameFlattening.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right">
            <q-toggle
              :model-value="cnameFlattening"
              :disable="isAnythingSaving || isLoading"
              @update:model-value="(val) => updateSetting('cnameFlattening', val)"
            />
          </div>
        </q-card-section>
      </q-card>

      <!-- Email Security -->
      <q-card flat bordered class="q-mb-md">
        <q-inner-loading :showing="isAnythingSaving" />
        <q-card-section class="row items-start justify-between">
          <div class="col-xs-12 col-md-9 q-pr-md">
            <div class="text-h6">{{ t('dns.settingsPage.emailSecurity.title') }}</div>
            <p class="text-body2 text-grey-8 q-mt-sm">
              {{ t('dns.settingsPage.emailSecurity.description') }}
            </p>
          </div>
          <div class="col-xs-12 col-md-3 text-md-right q-mt-sm q-mt-md-none">
            <q-btn
              color="primary"
              :label="t('dns.settingsPage.emailSecurity.configureBtn')"
              @click="showWorkInProgress"
            />
          </div>
        </q-card-section>
        <q-separator />
        <q-card-actions align="right" class="q-pa-md">
          <q-btn
            flat
            dense
            no-caps
            color="primary"
            :label="t('dns.settingsPage.help')"
            icon-right="open_in_new"
          />
        </q-card-actions>
      </q-card>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';
import { useI18n } from 'src/composables/useI18n';
import { useQuasar } from 'quasar';
import { useZoneStore } from 'src/stores/zoneStore';
import { storeToRefs } from 'pinia';
import { useCloudflareApi } from 'src/composables/useCloudflareApi';
import type { DnssecDetails, DnsSetting } from 'src/types';
import DnssecDetailsModal from 'src/components/modals/DnssecDetailsModal.vue';

type SettingsMap = {
  [key: string]: DnsSetting | undefined;
};

type SavingStates = {
  dnssecStatus: boolean;
  multiSignerDnssec: boolean;
  multiProviderDns: boolean;
  cnameFlattening: boolean;
};

const { t, locale } = useI18n();
const $q = useQuasar();
const zoneStore = useZoneStore();
const { selectedZoneId, zones } = storeToRefs(zoneStore);
const {
  getDnsSettings,
  updateDnsSetting,
  getDnssec,
  updateDnssec,
  getDnsZoneSettings,
  updateDnsZoneSettings,
} = useCloudflareApi();

const isLoading = ref(true);
const savingStates = ref<SavingStates>({
  dnssecStatus: false,
  multiSignerDnssec: false,
  multiProviderDns: false,
  cnameFlattening: false,
});

const isAnythingSaving = computed(() => Object.values(savingStates.value).some((state) => state));

const multiSignerDnssec = ref(false);
const multiProviderDns = ref(false);
const cnameFlattening = ref(false);
const dnssecStatus = ref<string | null>(null);
const dnssecDetails = ref<DnssecDetails | null>(null);

const currentZoneName = computed(
  () => zones.value.find((z) => z.id === selectedZoneId.value)?.name || '',
);

const isCloudflareRegistrar = computed(() => {
  const zone = zones.value.find((z) => z.id === selectedZoneId.value);
  return zone?.registrar?.name === 'cloudflare';
});

const dnsDocumentationLink = computed(() => {
  return locale.value === 'pt-BR'
    ? 'https://www.cloudflare.com/pt-br/learning/dns/dns-security/'
    : 'https://www.cloudflare.com/learning/dns/dns-security/';
});

const dnssecHelpLink = computed(() => {
  return locale.value === 'pt-BR'
    ? 'https://www.cloudflare.com/pt-br/learning/dns/dnssec/how-dnssec-works/'
    : 'https://www.cloudflare.com/learning/dns/dnssec/how-dnssec-works/';
});

const pollDnssecStatus = () => {
  setTimeout(() => {
    void fetchSettings();
  }, 3000);
  setTimeout(() => {
    void fetchSettings();
  }, 5000);
};

const fetchSettings = async () => {
  if (!selectedZoneId.value) return;

  isLoading.value = true;
  try {
    const [settingsResult, dnssecResult, dnsZoneSettingsResult] = await Promise.all([
      getDnsSettings(selectedZoneId.value),
      getDnssec(selectedZoneId.value),
      getDnsZoneSettings(selectedZoneId.value),
    ]);

    const settingsMap: SettingsMap = settingsResult.reduce(
      (acc: SettingsMap, setting: DnsSetting) => {
        acc[setting.id] = setting;
        return acc;
      },
      {},
    );

    dnssecDetails.value = dnssecResult;
    cnameFlattening.value = settingsMap.cname_flattening?.value === 'flatten_all';
    multiProviderDns.value = dnsZoneSettingsResult.multi_provider;
    multiSignerDnssec.value = !!dnssecResult.dnssec_multi_signer;
    dnssecStatus.value = dnssecResult.status;
  } catch (e: unknown) {
    const error = e instanceof Error ? e.message : String(e);
    $q.notify({
      color: 'negative',
      message: t('dns.settingsPage.toasts.fetchError', { error }),
    });
  } finally {
    isLoading.value = false;
  }
};

watch(selectedZoneId, fetchSettings, { immediate: true });

const updateSetting = async (key: keyof Omit<SavingStates, 'dnssecStatus'>, value: boolean) => {
  if (!selectedZoneId.value) return;

  savingStates.value[key] = true;
  const originalValues = {
    cnameFlattening: cnameFlattening.value,
    multiProviderDns: multiProviderDns.value,
    multiSignerDnssec: multiSignerDnssec.value,
  };

  // Optimistic UI update
  if (key === 'cnameFlattening') cnameFlattening.value = value;
  if (key === 'multiProviderDns') multiProviderDns.value = value;
  if (key === 'multiSignerDnssec') multiSignerDnssec.value = value;

  try {
    let settingName = '';
    if (key === 'cnameFlattening') {
      settingName = t('dns.settingsPage.cnameFlattening.title');
      const apiValue = value ? 'flatten_all' : 'flatten_at_root';
      await updateDnsSetting(selectedZoneId.value, 'cname_flattening', apiValue);
    } else if (key === 'multiProviderDns') {
      settingName = t('dns.settingsPage.multiProvider.title');
      await updateDnsZoneSettings(selectedZoneId.value, { multi_provider: value });
    } else if (key === 'multiSignerDnssec') {
      settingName = t('dns.settingsPage.multiSigner.title');
      await updateDnssec(selectedZoneId.value, { dnssec_multi_signer: value });
    }

    $q.notify({
      color: 'positive',
      message: t('dns.settingsPage.toasts.updateSuccess', { setting: settingName }),
    });
  } catch (e: unknown) {
    // Revert UI on error
    cnameFlattening.value = originalValues.cnameFlattening;
    multiProviderDns.value = originalValues.multiProviderDns;
    multiSignerDnssec.value = originalValues.multiSignerDnssec;

    const error = e instanceof Error ? e.message : String(e);
    $q.notify({
      color: 'negative',
      message: t('dns.settingsPage.toasts.updateError', { setting: key, error }),
    });
  } finally {
    savingStates.value[key] = false;
  }
};

const showDnssecDetails = () => {
  if (!dnssecDetails.value) {
    $q.notify({
      color: 'negative',
      message: 'DNSSEC details are not available.',
    });
    return;
  }
  $q.dialog({
    component: DnssecDetailsModal,
    componentProps: {
      dnssecDetails: dnssecDetails.value,
    },
  });
};

const handleEnableDnssec = async () => {
  if (!selectedZoneId.value) return;
  savingStates.value.dnssecStatus = true;
  try {
    const details = await updateDnssec(selectedZoneId.value, { status: 'active' });
    dnssecDetails.value = details;

    await fetchSettings();
    pollDnssecStatus();

    if (isCloudflareRegistrar.value) {
      $q.notify({
        color: 'positive',
        message: t('dns.settingsPage.toasts.dnssecEnableSuccessCF'),
        timeout: 5000,
      });
    } else {
      $q.dialog({
        component: DnssecDetailsModal,
        componentProps: {
          dnssecDetails: details,
        },
      });
    }
  } catch (e: unknown) {
    const error = e instanceof Error ? e.message : String(e);
    $q.notify({
      color: 'negative',
      message: t('dns.settingsPage.toasts.dnssecEnableError', { error }),
    });
  } finally {
    savingStates.value.dnssecStatus = false;
  }
};

const handleCancelDnssecSetup = () => {
  $q.dialog({
    title: t('dns.settingsPage.dnssecCard.cancelConfirmationTitle'),
    message: t('dns.settingsPage.dnssecCard.cancelConfirmationMessage'),
    cancel: true,
    persistent: true,
  }).onOk(() => {
    void (async () => {
      if (!selectedZoneId.value) return;
      savingStates.value.dnssecStatus = true;
      try {
        await updateDnssec(selectedZoneId.value, { status: 'disabled' });
        $q.notify({ color: 'positive', message: t('dns.settingsPage.toasts.dnssecCancelSuccess') });
        await fetchSettings();
        pollDnssecStatus();
      } catch (e: unknown) {
        const error = e instanceof Error ? e.message : String(e);
        $q.notify({
          color: 'negative',
          message: t('dns.settingsPage.toasts.dnssecCancelError', { error }),
        });
      } finally {
        savingStates.value.dnssecStatus = false;
      }
    })();
  });
};

const handleDisableDnssec = () => {
  $q.dialog({
    title: t('dns.settingsPage.dnssecCard.disableConfirmationTitle'),
    message: t('dns.settingsPage.dnssecCard.disableConfirmationMessage'),
    cancel: true,
    persistent: true,
  }).onOk(() => {
    void (async () => {
      if (!selectedZoneId.value) return;
      savingStates.value.dnssecStatus = true;
      try {
        await updateDnssec(selectedZoneId.value, { status: 'disabled' });
        $q.notify({
          color: 'positive',
          message: t('dns.settingsPage.toasts.dnssecDisableSuccess'),
        });
        await fetchSettings();
        pollDnssecStatus();
      } catch (e: unknown) {
        const error = e instanceof Error ? e.message : String(e);
        $q.notify({
          color: 'negative',
          message: t('dns.settingsPage.toasts.dnssecDisableError', { error }),
        });
      } finally {
        savingStates.value.dnssecStatus = false;
      }
    })();
  });
};

const handleCancelDnssecDeletion = () => {
  $q.dialog({
    title: t('dns.settingsPage.dnssecCard.cancelDeletionConfirmationTitle'),
    message: t('dns.settingsPage.dnssecCard.cancelDeletionConfirmationMessage'),
    cancel: true,
    persistent: true,
  }).onOk(() => {
    void (async () => {
      if (!selectedZoneId.value) return;
      savingStates.value.dnssecStatus = true;
      try {
        await updateDnssec(selectedZoneId.value, { status: 'active' });
        $q.notify({
          color: 'positive',
          message: t('dns.settingsPage.toasts.dnssecCancelDeletionSuccess'),
        });
        await fetchSettings();
        pollDnssecStatus();
      } catch (e: unknown) {
        const error = e instanceof Error ? e.message : String(e);
        $q.notify({
          color: 'negative',
          message: t('dns.settingsPage.toasts.dnssecCancelDeletionError', { error }),
        });
      } finally {
        savingStates.value.dnssecStatus = false;
      }
    })();
  });
};

const showWorkInProgress = () => {
  $q.notify({
    message: t('common.workInProgress'),
    color: 'info',
    position: 'top',
  });
};
</script>

<style lang="scss" scoped>
.text-body2 a {
  text-decoration: none;
  font-weight: 500;
}
</style>
