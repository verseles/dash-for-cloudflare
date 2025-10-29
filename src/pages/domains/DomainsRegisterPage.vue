<template>
  <q-page class="q-pa-md">
    <div class="text-h6">Register Domain</div>
    <q-input
      v-model="searchQuery"
      filled
      label="Search for domains"
      hint="Enter one or more domain names, separated by commas"
      class="q-mb-md"
    />
    <q-btn
      label="Search"
      color="primary"
      @click="searchDomains"
      :loading="isSearching"
      :disable="!searchQuery"
    />
    <div v-if="searchResults.length > 0" class="q-mt-md">
      <q-list bordered separator>
        <q-item v-for="result in searchResults" :key="result.domain">
          <q-item-section>
            <q-item-label>{{ result.domain }}</q-item-label>
          </q-item-section>
          <q-item-section side>
            <q-badge
              :color="result.available ? 'green' : 'red'"
              :label="result.available ? 'Available' : 'Not Available'"
            />
          </q-item-section>
        </q-item>
      </q-list>
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useWhoApi } from 'src/composables/useWhoApi'
import { useQuasar } from 'quasar'

const searchQuery = ref('')
const isSearching = ref(false)
const searchResults = ref<{ domain: string; available: boolean }[]>([])
const { checkDomainAvailability } = useWhoApi()
const $q = useQuasar()

const searchDomains = async () => {
  isSearching.value = true
  searchResults.value = []
  const domains = searchQuery.value.split(',').map(d => d.trim())

  const promises = domains.map(async domain => {
    try {
      const available = await checkDomainAvailability(domain)
      return { domain, available }
    } catch (error) {
      $q.notify({
        color: 'negative',
        message: `Error checking domain ${domain}: ${(error as Error).message}`,
      })
      return { domain, available: false }
    }
  })

  searchResults.value = await Promise.all(promises)
  isSearching.value = false
}
</script>