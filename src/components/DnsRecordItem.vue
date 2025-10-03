<template>
  <q-slide-item @right="(details) => onRight(details, record)">
    <template #right>
      <q-icon name="delete" />
    </template>

    <q-item 
      clickable 
      @click="onItemClick"
      :class="{
        'item-highlight-new': isNewRecord,
        'item-highlight-delete': isDeleting
      }"
    >
      <q-item-section>
        <!-- First row: Type, Name, TTL, Toggle -->
        <div class="row items-center q-gutter-x-sm">
          <!-- Type chip -->
          <div class="col-auto">
            <q-chip color="grey-7" text-color="white" square size="sm">
              {{ record.type }}
            </q-chip>
          </div>

          <!-- Name (takes remaining space) -->
          <div class="col ellipsis">
            <strong class="ellipsis">{{ mainName }}</strong>
            <span v-if="domainSuffix" class="domain-suffix">{{ domainSuffix }}</span>
          </div>

          <!-- TTL (always on right) -->
          <div class="col-auto text-caption text-grey">
            {{ record.ttl === 1 ? 'Auto' : record.ttl }}
          </div>

          <!-- Toggle (always on right) -->
          <div v-if="supportsProxy" class="col-auto">
            <q-toggle
              :model-value="localProxied"
              :checked-color="localProxied ? 'orange' : 'grey'"
              :disable="!isEditable || isSaving"
              size="sm"
              @update:model-value="onToggleChange"
              @click.stop
            />
          </div>
        </div>

        <!-- Second row: Content/Value -->
        <div class="q-mt-xs">
          <code class="dns-value">{{ record.content }}</code>
        </div>
      </q-item-section>
    </q-item>
  </q-slide-item>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import type { DnsRecord } from 'src/types';

const props = defineProps<{
  record: DnsRecord;
  isSaving: boolean;
  zoneName?: string;
  isNewRecord?: boolean;
  isDeleting?: boolean;
}>();

const emit = defineEmits(['save', 'delete', 'edit']);

// Local state for immediate UI feedback
const localProxied = ref(props.record.proxied);

// Watch for changes in the record prop to update local state
watch(
  () => props.record.proxied,
  (newValue) => {
    localProxied.value = newValue;
  }
);

const onToggleChange = (value: boolean) => {
  // Update local state immediately for better UX
  localProxied.value = value;
  // Emit the save event
  emit('save', { ...props.record, proxied: value });
};

const onItemClick = () => {
  emit('edit', props.record);
};

const onRight = (details: { reset: () => void }, recordToDelete: DnsRecord) => {
  emit('delete', recordToDelete);
  details.reset(); // It's important to call this to reset the item to its initial state
};

const isEditable = computed(() => {
  return ['A', 'AAAA', 'CNAME'].includes(props.record.type);
});

const supportsProxy = computed(() => {
  return ['A', 'AAAA', 'CNAME'].includes(props.record.type);
});

const mainName = computed(() => {
  if (!props.zoneName) return props.record.name;
  if (props.record.name === props.zoneName) {
    return '@';
  }
  if (props.record.name.endsWith('.' + props.zoneName)) {
    return props.record.name.replace('.' + props.zoneName, '');
  }
  return props.record.name;
});

const domainSuffix = computed(() => {
  if (!props.zoneName) return '';
  if (props.record.name === props.zoneName) {
    return '';
  }
  if (props.record.name.endsWith('.' + props.zoneName)) {
    return '.' + props.zoneName;
  }
  return '';
});
</script>

<style scoped>
.dns-value {
  font-family: 'Courier New', Courier, monospace;
  background-color: rgba(0, 0, 0, 0.05);
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85em;
  display: inline-block;
  word-break: break-all;
  max-width: 100%;
}

.body--dark .dns-value {
  background-color: rgba(255, 255, 255, 0.1);
}

.ellipsis {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.domain-suffix {
  color: #9e9e9e;
  font-weight: normal;
}

.body--dark .domain-suffix {
  color: #757575;
}

/* Highlight animation for new records */
@keyframes highlight-new {
  0% {
    background-color: rgba(76, 175, 80, 0.3);
  }
  100% {
    background-color: transparent;
  }
}

.item-highlight-new {
  animation: highlight-new 2s ease-out;
}

/* Highlight animation for deleting records */
@keyframes highlight-delete {
  0%, 100% {
    background-color: transparent;
  }
  50% {
    background-color: rgba(244, 67, 54, 0.3);
  }
}

.item-highlight-delete {
  animation: highlight-delete 0.6s ease-in-out 2;
}

/* Ensure consistent spacing on mobile */
@media (max-width: 599px) {
  .q-item {
    padding: 12px 16px;
  }
}
</style>
