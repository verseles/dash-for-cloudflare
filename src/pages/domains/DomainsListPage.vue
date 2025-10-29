<template>
  <q-page class="q-pa-md">
    <div v-if="isLoadingDomains" class="flex flex-center">
      <q-spinner-dots color="primary" size="40px" />
    </div>
    <div v-else-if="operationError" class="text-red">
      {{ operationError }}
    </div>
    <div v-else>
      <q-list bordered separator>
        <q-item v-for="domain in domains" :key="domain.id">
          <q-item-section>
            <q-item-label>{{ domain.name }}</q-item-label>
            <q-item-label caption>Expires on {{ new Date(domain.expires_at).toLocaleDateString() }}</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-badge :color="domain.locked ? 'green' : 'red'" :label="domain.locked ? 'Locked' : 'Unlocked'" />
          </q-item-section>
        </q-item>
      </q-list>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useDomainStore } from 'src/stores/domainStore'

const domainStore = useDomainStore()
const { domains, isLoadingDomains, operationError } = storeToRefs(domainStore)

onMounted(() => {
  void domainStore.fetchDomains()
})
</script>