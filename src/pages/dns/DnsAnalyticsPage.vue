<template>
  <q-page padding>
    <div class="q-mb-md row justify-between items-center">
      <div class="text-h6">{{ t('dns.analytics.title') }}</div>
      <q-btn-toggle
        v-model="timeRange"
        :options="timeRangeOptions"
        toggle-color="primary"
        unelevated
        dense
      />
    </div>

    <div v-if="isLoading && !analyticsData" class="flex flex-center" style="height: 50vh">
      <q-spinner-dots color="primary" size="40px" />
    </div>

    <q-banner v-else-if="error" inline-actions class="text-white bg-red">
      {{ error }}
    </q-banner>

    <div v-else-if="analyticsData" class="q-gutter-y-md">
      <!-- Summary Cards -->
      <div class="row q-gutter-md">
        <q-card class="col" flat bordered>
          <q-card-section>
            <div class="text-subtitle2">Total Queries</div>
            <div class="text-h5">{{ totalQueries.toLocaleString() }}</div>
          </q-card-section>
        </q-card>
      </div>

      <!-- Top Lists -->
      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <q-table
            title="Top Query Names"
            :rows="topQueryNames"
            :columns="queryNameColumns"
            row-key="name"
            flat
            bordered
            hide-pagination
            :pagination="{ rowsPerPage: 10 }"
          />
        </div>
        <div class="col-12 col-md-6">
          <q-table
            title="Top Query Types"
            :rows="topQueryTypes"
            :columns="queryTypeColumns"
            row-key="type"
            flat
            bordered
            hide-pagination
            :pagination="{ rowsPerPage: 10 }"
          />
        </div>
        <div class="col-12">
          <q-table
            title="Top Response Codes"
            :rows="topResponseCodes"
            :columns="responseCodeColumns"
            row-key="code"
            flat
            bordered
            hide-pagination
            :pagination="{ rowsPerPage: 10 }"
           />
        </div>
      </div>
    </div>
     <div v-else class="text-center q-pa-xl text-grey-7">
      No analytics data to display for the selected period.
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';
import { useI18n } from 'src/composables/useI18n';
import { useDnsAnalytics } from 'src/composables/useDnsAnalytics';
import { useZoneStore } from 'src/stores/zoneStore';
import { storeToRefs } from 'pinia';
import type { QTableColumn } from 'quasar';

const { t } = useI18n();
const { analyticsData, isLoading, error, fetchAnalytics } = useDnsAnalytics();
const zoneStore = useZoneStore();
const { selectedZoneId } = storeToRefs(zoneStore);

const timeRange = ref('24h');

const timeRangeOptions = [
  { label: '24 Hours', value: '24h' },
  { label: '7 Days', value: '7d' },
  { label: '30 Days', value: '30d' },
];

const fetchData = () => {
  const until = new Date();
  const since = new Date();
  
  switch (timeRange.value) {
    case '7d':
      since.setDate(until.getDate() - 7);
      break;
    case '30d':
      since.setDate(until.getDate() - 30);
      break;
    case '24h':
    default:
      since.setHours(until.getHours() - 24);
      break;
  }
  
  void fetchAnalytics(since, until);
};

watch([timeRange, selectedZoneId], fetchData, { immediate: true });

const totalQueries = computed(() => analyticsData.value?.total[0]?.count || 0);

const topQueryNames = computed(() => 
  analyticsData.value?.topQueryNames.map(item => ({
    name: item.dimensions.queryName,
    count: item.count
  })) || []
);

const topQueryTypes = computed(() =>
  analyticsData.value?.topQueryTypes.map(item => ({
    type: item.dimensions.queryType,
    count: item.count
  })) || []
);

const topResponseCodes = computed(() =>
  analyticsData.value?.topResponseCodes.map(item => ({
    code: item.dimensions.responseCode,
    count: item.count
  })) || []
);

const queryNameColumns: QTableColumn[] = [
  { name: 'name', required: true, label: 'Query Name', align: 'left', field: 'name', sortable: true },
  { name: 'count', label: 'Count', field: 'count', sortable: true, align: 'right' },
];

const queryTypeColumns: QTableColumn[] = [
  { name: 'type', required: true, label: 'Query Type', align: 'left', field: 'type', sortable: true },
  { name: 'count', label: 'Count', field: 'count', sortable: true, align: 'right' },
];

const responseCodeColumns: QTableColumn[] = [
  { name: 'code', required: true, label: 'Response Code', align: 'left', field: 'code', sortable: true },
  { name: 'count', label: 'Count', field: 'count', sortable: true, align: 'right' },
];

</script>