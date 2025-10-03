<template>
  <q-layout view="lHh Lpr lFf">
    <q-header>
      <q-toolbar>
        <q-btn flat dense round icon="menu" aria-label="Menu" @click="toggleLeftDrawer" />

        <q-toolbar-title> Dash for Cloudflare </q-toolbar-title>

        <q-spinner v-if="loadingStore.isLoading" color="white" size="1.5em" />
      </q-toolbar>
    </q-header>

    <q-drawer v-model="leftDrawerOpen" show-if-above bordered>
      <q-list>
        <q-item-label header>Menu</q-item-label>

        <q-item v-for="link in menuList" :key="link.to" clickable :to="link.to" exact>
          <q-item-section v-if="link.icon" avatar>
            <q-icon :name="link.icon" />
          </q-item-section>

          <q-item-section>
            <q-item-label>{{ link.title }}</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import { useI18n } from 'src/composables/useI18n';
import { useLoadingStore } from 'src/stores/loading';

const { t } = useI18n();
const loadingStore = useLoadingStore();

const menuList = computed(() => [
  {
    title: t('menu.dns'),
    to: '/dns',
    icon: 'dns',
  },
  {
    title: t('menu.settings'),
    to: '/settings',
    icon: 'settings',
  },
]);

const leftDrawerOpen = ref(false);

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value;
}
</script>
