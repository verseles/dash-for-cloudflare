<template>
  <q-page class="flex column" style="padding-bottom: 80px">
    <!-- The router-view will render the content of the active tab -->
    <router-view class="col" />

    <!-- Sticky tabs at the bottom for sub-navigation -->
    <q-page-sticky expand position="bottom">
      <q-tabs
        v-model="tab"
        class="bg-primary text-white shadow-2 full-width"
        align="justify"
        no-caps
        indicator-color="transparent"
        active-color="white"
      >
        <q-route-tab to="/dns/records" icon="list" :label="t('dns.tabs.records')" />
        <q-route-tab to="/dns/analytics" icon="analytics" :label="t('dns.tabs.analytics')" />
        <q-route-tab to="/dns/settings" icon="settings" :label="t('dns.tabs.settings')" />
      </q-tabs>
    </q-page-sticky>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useI18n } from 'src/composables/useI18n';

const { t } = useI18n();
const tab = ref('records'); // This will be automatically managed by q-route-tab
</script>
