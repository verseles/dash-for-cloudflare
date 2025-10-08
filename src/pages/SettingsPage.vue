<template>
  <q-page padding>
    <q-list class="q-mx-auto" style="max-width: 600px">
      <q-item-label header>API</q-item-label>
      <q-item>
        <q-item-section>
          <q-input
            v-model="settings.cloudflareApiToken"
            :label="t('settings.apiToken')"
            stack-label
            type="password"
            :placeholder="t('settings.apiTokenPlaceholder')"
            :hint="t('settings.apiTokenHint')"
            :error-message="tokenError"
            :error="!!tokenError"
            @update:model-value="validateToken"
          />
          <div class="q-mt-sm text-caption text-grey-7">
            {{ t('settings.apiTokenHelp.title') }}
            <ul class="q-pl-md q-my-xs" style="list-style-position: inside">
              <li>{{ t('settings.apiTokenHelp.dns') }}</li>
              <li>{{ t('settings.apiTokenHelp.analytics') }}</li>
              <li>{{ t('settings.apiTokenHelp.dnsSettings') }}</li>
            </ul>
            <div class="q-mt-sm">
              <a
                href="https://dash.cloudflare.com/profile/api-tokens"
                target="_blank"
                class="row items-center no-wrap"
                style="text-decoration: none; color: blue"
              >
                {{ t('settings.apiTokenHelp.createTokenLink') }}
                <q-icon name="open_in_new" size="xs" class="q-ml-xs" />
              </a>
            </div>
          </div>
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

      <q-item-label header>{{ t('settings.appearance') }}</q-item-label>
      <q-item>
        <q-item-section>
          <q-btn-toggle
            v-model="settings.theme"
            :options="themeOptions"
            class="full-width q-mb-sm"
            toggle-color="primary"
            unelevated
            spread
          />
        </q-item-section>
      </q-item>

      <q-item-label header>{{ t('settings.language') }}</q-item-label>
      <q-item>
        <q-item-section>
          <q-select
            v-model="settings.language"
            :label="t('settings.language')"
            :options="languageOptions"
            emit-value
            map-options
            standout
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
};

// Watch for changes
watch(() => settings.theme, () => {
  // No-op: Just trigger reactivity
});
watch(() => settings.language, () => {
  // No-op: Just trigger reactivity
});

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
  { value: 'light', label: t('settings.light') },
  { value: 'auto', label: t('settings.uiModeOptions.auto') },
  { value: 'dark', label: t('settings.dark') },
];

const languageOptions = [
  { value: 'en-US', label: t('settings.languageOptions.en') },
  { value: 'pt-BR', label: t('settings.languageOptions.ptBR') },
];
</script>