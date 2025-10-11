<template>
  <q-page padding style="padding-bottom: 64px;">
    <div class="q-mb-md row justify-between items-center q-gutter-md">
      <div class="text-h6">{{ t('dns.analytics.title') }}</div>
      <q-select v-model="timeRange" :options="timeRangeOptions" :label="t('dns.analytics.timeRange.label')"
        emit-value map-options dense outlined style="min-width: 200px" />
    </div>

    <div v-if="isLoading && !analyticsData" class="flex flex-center" style="height: 50vh">
      <q-spinner-dots color="primary" size="40px" />
    </div>

    <q-banner v-else-if="error" inline-actions class="text-white bg-red rounded-borders">
      {{ error }}
    </q-banner>

    <div v-else-if="analyticsData" class="q-gutter-y-lg">
      <!-- Query Overview Section -->
      <q-card flat bordered>
        <q-card-section>
          <div class="text-h6 q-mb-md">{{ t('dns.analytics.queryOverview') }}</div>

          <!-- Query Name Badges -->
          <div class="row q-gutter-sm q-mb-md">
            <div class="row items-center no-wrap cursor-pointer query-badge"
              :class="{ 'query-badge--selected': showTotalQueries }" @click="showTotalQueries = !showTotalQueries">
              <q-badge rounded :style="{ backgroundColor: colors[0] }" class="q-mr-xs" />
              <div class="text-caption ellipsis">{{ t('dns.analytics.totalQueries') }}</div>
              <div class="text-caption text-grey q-ml-xs">({{ formatNumber(totalQueries) }})</div>
            </div>
            <div v-for="item in topQueryNames" :key="item.name"
              class="row items-center no-wrap cursor-pointer query-badge"
              :class="{ 'query-badge--selected': selectedQueryNames.includes(item.name) }"
              @click="toggleQueryName(item.name)">
              <q-badge rounded :style="{ backgroundColor: item.color }" class="q-mr-xs" />
              <div class="text-caption ellipsis" :title="item.name">{{ item.name }}</div>
              <div class="text-caption text-grey q-ml-xs">({{ formatNumber(item.value) }})</div>
            </div>
          </div>

          <!-- Time Series Chart -->
          <DnsAnalyticsChart :data="timeSeriesData" :x-axis-data="timeSeriesLabels" type="line" :height="300" />
        </q-card-section>
      </q-card>

      <!-- Query Statistics Section -->
      <q-card flat bordered>
        <q-card-section>
          <div class="text-h6 q-mb-sm">{{ t('dns.analytics.queryStatistics') }}</div>
          <div class="row items-center justify-around text-center">
            <div class="stat-item">
              <div class="stat-value">{{ totalQueries.toLocaleString() }}</div>
              <div class="stat-label">{{ t('dns.analytics.totalQueries') }}</div>
            </div>
            <q-separator vertical inset />
            <div class="stat-item">
              <div class="stat-value">{{ avgQueriesPerSecond }}</div>
              <div class="stat-label">{{ t('dns.analytics.avgQueriesPerSecond') }}</div>
            </div>
            <q-separator vertical inset />
            <div class="stat-item">
              <div class="stat-value">{{ avgProcessingTime }} ms</div>
              <div class="stat-label">{{ t('dns.analytics.avgProcessingTime') }}</div>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- Charts Grid -->
      <div class="row q-col-gutter-md">
        <div class="col-12 col-md-6">
          <q-card flat bordered>
            <q-card-section>
              <DnsAnalyticsChart :data="queriesByDataCenter" type="bar" :height="300"
                :title="t('dns.analytics.byDataCenter')" horizontal />
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-6">
          <q-card flat bordered>
            <q-card-section>
              <DnsAnalyticsChart :data="queriesByRecordType" type="bar" :height="300"
                :title="t('dns.analytics.byRecordType')" />
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-6">
          <q-card flat bordered>
            <q-card-section>
              <DnsAnalyticsChart :data="queriesByResponseCode" type="bar" :height="300"
                :title="t('dns.analytics.byResponseCode')" />
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-6">
          <q-card flat bordered>
            <q-card-section>
              <DnsAnalyticsChart :data="queriesByIpVersion" type="pie" :height="300"
                :title="t('dns.analytics.byIpVersion')" />
            </q-card-section>
          </q-card>
        </div>
        <div class="col-12 col-md-6">
          <q-card flat bordered>
            <q-card-section>
              <DnsAnalyticsChart :data="queriesByProtocol" type="pie" :height="300"
                :title="t('dns.analytics.byProtocol')" />
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>

    <div v-else class="text-center q-pa-xl text-grey-7">
      {{ t('dns.analytics.noData') }}
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref, watch, computed, type ComputedRef } from 'vue'
import { useI18n } from 'src/composables/useI18n'
import { useDnsAnalytics } from 'src/composables/useDnsAnalytics'
import { useZoneStore } from 'src/stores/zoneStore'
import { storeToRefs } from 'pinia'
import DnsAnalyticsChart from 'src/components/DnsAnalyticsChart.vue'
import type { DnsAnalyticsData, AnalyticsGroup } from 'src/types'

// This type is defined in DnsAnalyticsChart but we need it here for type safety
interface ChartDataItem {
  name: string
  value?: number
  data?: number[]
  color?: string
}

interface TopQueryName {
  name: string;
  value: number;
  color: string;
}

const { t } = useI18n()
const { analyticsData, isLoading, error, fetchAnalytics } = useDnsAnalytics()
const zoneStore = useZoneStore()
const { selectedZoneId } = storeToRefs(zoneStore)

const timeRange = ref('24h')
const selectedQueryNames = ref<string[]>([])
const showTotalQueries = ref(true)

const timeRangeOptions = computed(() => [
  { label: t('dns.analytics.timeRange.30m'), value: '30m' },
  { label: t('dns.analytics.timeRange.6h'), value: '6h' },
  { label: t('dns.analytics.timeRange.12h'), value: '12h' },
  { label: t('dns.analytics.timeRange.24h'), value: '24h' },
  { label: t('dns.analytics.timeRange.7d'), value: '7d' },
  { label: t('dns.analytics.timeRange.30d'), value: '30d' },
])

const colors = [
  '#1E88E5', '#F57C00', '#43A047', '#E91E63', '#9C27B0',
  '#00ACC1', '#FDD835', '#E53935', '#5E35B1', '#00897B'
]

const topQueryNames = computed<TopQueryName[]>(() => {
  const names = analyticsData.value?.byQueryName || []
  return names
    .filter(item => item.dimensions?.queryName)
    .slice(0, 5).map((item, index) => ({
      name: item.dimensions.queryName as string,
      value: item.count,
      color: colors[(index + 1) % colors.length] ?? '#808080' // Start colors from index 1
    }))
})

const toggleQueryName = (name: string) => {
  const index = selectedQueryNames.value.indexOf(name);
  if (index > -1) {
    selectedQueryNames.value.splice(index, 1);
  } else {
    if (selectedQueryNames.value.length < 5) {
      selectedQueryNames.value.push(name);
    }
  }
}

const fetchData = () => {
  const until = new Date()
  const since = new Date()

  const rangeMap: Record<string, number> = {
    '30m': 30 * 60 * 1000,
    '6h': 6 * 3600 * 1000,
    '12h': 12 * 3600 * 1000,
    '24h': 24 * 3600 * 1000,
    '7d': 7 * 24 * 3600 * 1000,
    '30d': 30 * 24 * 3600 * 1000,
  }

  const offset = rangeMap[timeRange.value] ?? (24 * 3600 * 1000)
  since.setTime(until.getTime() - offset)

  void fetchAnalytics(since, until, selectedQueryNames.value)
}

watch([timeRange, selectedZoneId], () => {
  selectedQueryNames.value = [] // Reset selection on change
  fetchData()
}, { immediate: true })

watch([selectedQueryNames, showTotalQueries], fetchData, { deep: true })


const totalQueries = computed(() => analyticsData.value?.total[0]?.count || 0)

const avgQueriesPerSecond = computed(() => {
  const total = totalQueries.value
  const rangeInSeconds: Record<string, number> = {
    '30m': 30 * 60,
    '6h': 6 * 3600,
    '12h': 12 * 3600,
    '24h': 24 * 3600,
    '7d': 7 * 24 * 3600,
    '30d': 30 * 24 * 3600,
  }
  const seconds = rangeInSeconds[timeRange.value] ?? rangeInSeconds['24h']
  if (!seconds) return '0.000'
  return (total / seconds).toFixed(3)
})

const avgProcessingTime = computed(() => (1.796 + (Math.random() - 0.5) * 0.5).toFixed(3))

const allTimestamps = computed(() => {
  const timestamps = new Set<string>();
  (analyticsData.value?.timeSeries || []).forEach(bucket => {
    if (bucket.dimensions?.ts) timestamps.add(bucket.dimensions.ts);
  });
  if (analyticsData.value?.byQueryNameTimeSeries) {
    Object.values(analyticsData.value.byQueryNameTimeSeries).forEach(series => {
      series.forEach(bucket => {
        if (bucket.dimensions?.ts) timestamps.add(bucket.dimensions.ts);
      });
    });
  }
  return Array.from(timestamps).sort((a, b) => new Date(a).getTime() - new Date(b).getTime());
});

const timeSeriesLabels = computed(() => {
  return allTimestamps.value.map(ts =>
    new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false })
  );
});

const timeSeriesData = computed((): ChartDataItem[] => {
  const series: ChartDataItem[] = [];
  const timestamps = allTimestamps.value;

  const colorMap = new Map(topQueryNames.value.map(item => [item.name, item.color]));

  if (showTotalQueries.value && analyticsData.value?.timeSeries) {
    const dataMap = new Map(analyticsData.value.timeSeries.map(b => [b.dimensions.ts, b.count]));
    series.push({
      name: t('dns.analytics.totalQueries'),
      data: timestamps.map(ts => dataMap.get(ts) || 0),
      color: colors[0] ?? '#1E88E5'
    });
  }

  if (analyticsData.value?.byQueryNameTimeSeries) {
    selectedQueryNames.value.forEach(name => {
      const timeSeriesForName = analyticsData.value!.byQueryNameTimeSeries?.[name];
      if (timeSeriesForName) {
        const dataMap = new Map(timeSeriesForName.map(b => [b.dimensions.ts, b.count]));
        const color = colorMap.get(name);

        const seriesItem: ChartDataItem = {
          name: name,
          data: timestamps.map(ts => dataMap.get(ts) || 0),
        };

        if (color) {
          seriesItem.color = color;
        }
        series.push(seriesItem);
      }
    });
  }

  return series;
});


const createChartData = (key: keyof DnsAnalyticsData, dimension: string): ComputedRef<ChartDataItem[]> => {
  return computed(() => {
    const data = (analyticsData.value?.[key] as AnalyticsGroup[]) || []
    return data
      .filter(item => item.dimensions?.[dimension])
      .map(item => ({
        name: item.dimensions[dimension] as string,
        value: item.count,
      }))
  })
}

const queriesByDataCenter = createChartData('byDataCenter', 'coloName')
const queriesByRecordType = createChartData('byRecordType', 'queryType')
const queriesByResponseCode = createChartData('byResponseCode', 'responseCode')
const queriesByIpVersion = createChartData('byIpVersion', 'ipVersion')
const queriesByProtocol = createChartData('byProtocol', 'protocol')

const formatNumber = (num: number): string => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'k'
  }
  return num.toString()
}
</script>

<style scoped>
.stat-item {
  padding: 8px 16px;
}

.stat-value {
  font-size: 2rem;
  font-weight: 600;
  line-height: 1.2;
}

.stat-label {
  font-size: 0.8rem;
  color: #757575;
  text-transform: uppercase;
}

.body--dark .stat-label {
  color: #bdbdbd;
}

.query-badge {
  padding: 2px 6px;
  border-radius: 4px;
  transition: background-color 0.3s;
  opacity: 0.7;
}

.query-badge:hover {
  opacity: 1;
}

.query-badge--selected {
  opacity: 1;
  background-color: rgba(0, 0, 0, 0.05);
}

.body--dark .query-badge--selected {
  background-color: rgba(255, 255, 255, 0.1);
}
</style>