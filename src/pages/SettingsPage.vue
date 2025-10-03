<template>
  <q-page padding>
    <q-list bordered class="q-mx-auto" style="max-width: 600px">
      <q-item-label header>API</q-item-label>
      <q-item>
        <q-item-section>
          <q-input
            v-model="settings.cloudflareApiToken"
            :label="t('settings.apiToken')"
            stack-label
            type="password"
            :placeholder="t('settings.apiTokenPlaceholder')"
            :hint="t('settings.apiTokenHelp')"
            :error-message="tokenError"
            :error="!!tokenError"
            @update:model-value="validateToken"
          />
        </q-item-section>
      </q-item>

      <q-item v-if="settings.cloudflareApiToken && settings.cloudflareApiToken.length >= 40">
        <q-item-section>
          <q-btn
            color="primary"
            :label="t('settings.goToDns')"
            icon="dns"
            @click="navigateToDns"
            class="full-width"
          />
        </q-item-section>
      </q-item>

      <q-separator spaced />

      <q-item-label header>{{ t('settings.appearance') }}</q-item-label>
      <q-item>
        <q-item-section>
          <q-select
            v-model="settings.theme"
            :label="t('settings.darkMode')"
            :options="themeOptions"
            emit-value
            map-options
            stack-label
          />
        </q-item-section>
      </q-item>

      <q-separator spaced />

      <q-item-label header>{{ t('settings.language') }}</q-item-label>
      <q-item>
        <q-item-section>
          <q-select
            v-model="settings.language"
            :label="t('settings.language')"
            :options="languageOptions"
            emit-value
            map-options
            stack-label
          />
        </q-item-section>
      </q-item>
    </q-list>
  </q-page>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useSettings } from 'src/composables/useSettings';
import { useI18n } from 'src/composables/useI18n';
import { useQuasar } from 'quasar';
import { useRouter } from 'vue-router';

const { settings } = useSettings();
const { t } = useI18n();
const $q = useQuasar();
const router = useRouter();

const tokenError = ref('');

const validateToken = (token: string | number | null) => {
  const tokenString = typeof token === 'string' ? token : '';
  if (tokenString && tokenString.length > 0 && tokenString.length < 40) {
    tokenError.value = t('settings.apiTokenError');
  } else {
    tokenError.value = '';
  }

  // Show save confirmation when token is valid
  if (!tokenError.value && tokenString && tokenString.length >= 40) {
    $q.notify({
      message: t('settings.apiTokenSaved'),
      color: 'positive',
      position: 'top',
      timeout: 2000,
    });
  }
};

// Watch for changes and show confirmation
watch(
  () => settings.theme,
  () => {
    $q.notify({
      message: t('settings.themeSaved'),
      color: 'positive',
      position: 'top',
      timeout: 1500,
    });
  },
);

watch(
  () => settings.language,
  () => {
    $q.notify({
      message: t('settings.languageSaved'),
      color: 'positive',
      position: 'top',
      timeout: 1500,
    });
  },
);

const navigateToDns = () => {
  if (settings.cloudflareApiToken && settings.cloudflareApiToken.length >= 40) {
    void router.push('/dns');
  } else {
    $q.notify({
      message: t('settings.tokenRequired'),
      color: 'warning',
      position: 'top',
    });
  }
};

const themeOptions = [
  { value: 'auto', label: t('settings.uiModeOptions.auto') },
  { value: 'light', label: t('settings.light') },
  { value: 'dark', label: t('settings.dark') },
];

const languageOptions = [
  { value: 'en-US', label: t('settings.languageOptions.en') },
  { value: 'pt-BR', label: t('settings.languageOptions.ptBR') },
];
</script>
