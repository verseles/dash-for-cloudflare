<template>
  <q-toggle :model-value="modelValue" dense :checked-color="modelValue ? 'primary' : 'grey'" :disable="disable"
    :checked-icon="mdiCloud" size="xl" @update:model-value="(value) => emit('update:modelValue', value)" @click.stop>
    <q-tooltip v-if="tooltip" anchor="center left" self="center right">
      {{ t('dns.cloudflareProxy') }}
    </q-tooltip>
  </q-toggle>
</template>

<script setup lang="ts">
import { mdiCloud } from '@quasar/extras/mdi-v7';
import { useI18n } from 'src/composables/useI18n';

const { t } = useI18n();
defineProps<{
  modelValue: boolean;
  disable?: boolean;
  tooltip?: boolean;
}>();

const emit = defineEmits(['update:modelValue']);
</script>