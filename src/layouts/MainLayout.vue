<template>
  <q-layout view="lHh Lpr lFf">
    <q-header>
      <q-toolbar>
        <q-btn flat dense round icon="menu" aria-label="Menu" @click="toggleLeftDrawer" />

        <q-select v-if="shouldShowZoneSelector" v-model="selectedZoneId" :label="t('dns.zoneSelector')" stack-label
          :placeholder="t('dns.loadingZones')" :options="filteredZoneOptions" option-value="id" option-label="name"
          emit-value map-options :loading="isLoadingZones" :disable="isLoadingZones || !!operationError"
          class="full-width q-ml-md" borderless dense options-dense use-input fill-input hide-selected
          @filter="filterZones">
          <template #no-option>
            <q-item>
              <q-item-section class="text-grey">No results</q-item-section>
            </q-item>
          </template>
        </q-select>

        <q-toolbar-title v-else>Dash for Cloudflare</q-toolbar-title>

        <q-spinner v-if="isAnythingLoading" size="md" />
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

    <UpdateBanner v-model="updateExists" @update-app="updateApp" />
  </q-layout>
</template>

<script setup lang="ts">
import { computed, ref, watch, onMounted, onBeforeUnmount } from 'vue'
import { useRoute } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useI18n } from 'src/composables/useI18n'
import { useLoadingStore } from 'src/stores/loading'
import { useZoneStore } from 'src/stores/zoneStore'
import type { Zone } from 'src/types'
import UpdateBanner from 'src/components/UpdateBanner.vue'

const { t } = useI18n()
const route = useRoute()
const loadingStore = useLoadingStore()
const zoneStore = useZoneStore()

const { zones, selectedZoneId, isLoadingZones, operationError } = storeToRefs(zoneStore)

const filteredZoneOptions = ref<Zone[]>(zones.value)

watch(zones, (newZones) => {
  filteredZoneOptions.value = newZones
})

const filterZones = (val: string, update: (callback: () => void) => void) => {
  if (val === '') {
    update(() => {
      filteredZoneOptions.value = zones.value
    })
    return
  }

  update(() => {
    const needle = val.toLowerCase()
    const filtered = zones.value.filter((zone) => zone.name.toLowerCase().indexOf(needle) > -1)
    filteredZoneOptions.value = filtered

    // Autoselect if only one result and it's not already the selected one
    if (filtered.length === 1 && filtered[0] && selectedZoneId.value !== filtered[0].id) {
      selectedZoneId.value = filtered[0].id
    }
  })
}

const isAnythingLoading = computed(() => loadingStore.isLoading || zoneStore.isLoadingZones)

const shouldShowZoneSelector = computed(() => route.path.startsWith('/dns'))

const menuList = computed(() => [
  {
    title: t('menu.dns'),
    to: '/dns/records',
    icon: 'dns',
  },
  {
    title: t('menu.domains'),
    to: '/domains/list',
    icon: 'language',
  },
  {
    title: t('menu.settings'),
    to: '/settings',
    icon: 'settings',
  },
])

const leftDrawerOpen = ref(false)

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

// PWA Update Logic
const updateExists = ref(false)
const registration = ref<ServiceWorkerRegistration | null>(null)

function onSWUpdated(e: Event) {
  const reg = (e as CustomEvent).detail
  if (reg && reg.waiting) {
    registration.value = reg
    updateExists.value = true
  }
}

function updateApp() {
  if (registration.value && registration.value.waiting) {
    registration.value.waiting.postMessage({ type: 'SKIP_WAITING' })
  }
}

onMounted(() => {
  document.addEventListener('swUpdated', onSWUpdated, { once: true })
  // When the new service worker becomes active, refresh the page
  navigator.serviceWorker?.addEventListener('controllerchange', () => {
    window.location.reload()
  })
})

onBeforeUnmount(() => {
  document.removeEventListener('swUpdated', onSWUpdated)
})
</script>