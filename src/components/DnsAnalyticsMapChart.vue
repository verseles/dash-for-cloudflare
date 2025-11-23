<template>
  <div class="dns-analytics-chart">
    <div v-if="title" class="chart-title">{{ title }}</div>
    <v-chart :option="chartOption" :style="{ height: `${height}px`, width: '100%' }" autoresize />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { use, registerMap } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { EffectScatterChart } from 'echarts/charts';
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GeoComponent,
  VisualMapComponent,
} from 'echarts/components';
import VChart from 'vue-echarts';
import { useQuasar } from 'quasar';
import worldMapRaw from 'src/assets/world.json?raw';

// Register ECharts components and maps
use([
  CanvasRenderer,
  EffectScatterChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GeoComponent,
  VisualMapComponent,
]);

const worldMap = JSON.parse(worldMapRaw);
registerMap('world', worldMap as unknown as Parameters<typeof registerMap>[1]);

interface MapChartDataItem {
  name: string;
  value: [number, number, number]; // lng, lat, query count
}

interface Props {
  data: MapChartDataItem[];
  height?: number;
  title?: string;
}

const props = withDefaults(defineProps<Props>(), {
  height: 300,
  title: '',
});

const $q = useQuasar();
const isDark = computed(() => $q.dark.isActive);

const chartOption = computed(() => {
  const textColor = isDark.value ? '#E0E0E0' : '#424242';
  const backgroundColor = 'transparent';
  const mapColor = isDark.value ? '#333' : '#f2f2f2';
  const mapBorderColor = isDark.value ? '#555' : '#ccc';

  const maxVal = Math.max(...props.data.map((item) => item.value[2]));

  return {
    backgroundColor,
    textStyle: {
      color: textColor,
    },
    tooltip: {
      trigger: 'item',
      backgroundColor: isDark.value ? '#424242' : '#FFFFFF',
      borderColor: isDark.value ? '#616161' : '#E0E0E0',
      textStyle: {
        color: textColor,
      },
      formatter: (params: { data: MapChartDataItem }) => {
        const data = params.data;
        return `${data.name}<br/>Queries: ${data.value[2].toLocaleString()}`;
      },
    },
    geo: {
      map: 'world',
      roam: true,
      itemStyle: {
        areaColor: mapColor,
        borderColor: mapBorderColor,
      },
      emphasis: {
        itemStyle: {
          areaColor: isDark.value ? '#444' : '#e0e0e0',
        },
        label: {
          show: false,
        },
      },
    },
    visualMap: {
      show: false,
      min: 0,
      max: maxVal,
      inRange: {
        symbolSize: [5, 25],
      },
    },
    series: [
      {
        name: 'Queries',
        type: 'effectScatter',
        coordinateSystem: 'geo',
        data: props.data,
        rippleEffect: {
          brushType: 'stroke',
        },
        label: {
          show: false,
        },
        emphasis: {
          label: {
            show: true,
            formatter: '{b}',
            position: 'top',
          },
        },
      },
    ],
  };
});
</script>

<style scoped>
.dns-analytics-chart {
  width: 100%;
}

.chart-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
  color: inherit;
}
</style>
