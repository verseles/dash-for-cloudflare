<template>
    <q-page padding>
        <div class="text-h6">{{ t('dns.analytics.title') }}</div>
        <p>{{ t('dns.analytics.placeholder') }}</p>
    </q-page>
</template>

<script setup lang="ts">
import { useI18n } from 'src/composables/useI18n'

const { t } = useI18n()
</script>