<template>
  <q-banner
    v-if="isVisible"
    inline-actions
    class="bg-primary text-white q-ma-md"
    style="position: fixed; bottom: 0; left: 0; right: 0; z-index: 9999; border-radius: 8px"
  >
    {{ t('pwaUpdate.newVersionAvailable') }}
    <template #action>
      <q-btn flat color="white" :label="t('pwaUpdate.updateNow')" @click="handleUpdate" />
      <q-btn flat color="white" icon="close" @click="isVisible = false" />
    </template>
  </q-banner>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useI18n } from 'src/composables/useI18n';

const props = defineProps<{
  modelValue: boolean;
}>();

const emit = defineEmits(['update:modelValue', 'update-app']);

const { t } = useI18n();

const isVisible = ref(props.modelValue);

watch(
  () => props.modelValue,
  (val) => {
    isVisible.value = val;
  },
);

watch(isVisible, (val) => {
  if (val !== props.modelValue) {
    emit('update:modelValue', val);
  }
});

function handleUpdate() {
  emit('update-app');
  isVisible.value = false;
}
</script>
