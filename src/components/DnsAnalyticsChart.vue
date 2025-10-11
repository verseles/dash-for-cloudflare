<template>
    <div class="dns-analytics-chart">
        <div v-if="title" class="chart-title">{{ title }}</div>
        <v-chart :option="chartOption" :style="{ height: `${height}px`, width: '100%' }" autoresize />
    </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, PieChart, BarChart } from 'echarts/charts'
import {
    TitleComponent,
    TooltipComponent,
    LegendComponent,
    GridComponent,
} from 'echarts/components'
import VChart from 'vue-echarts'
import { useQuasar } from 'quasar'

use([
    CanvasRenderer,
    LineChart,
    PieChart,
    BarChart,
    TitleComponent,
    TooltipComponent,
    LegendComponent,
    GridComponent,
])

interface ChartDataItem {
    name: string
    value?: number
    data?: number[]
    color?: string
}

interface Props {
    data: ChartDataItem[]
    type: 'line' | 'pie' | 'bar'
    height?: number
    title?: string
    horizontal?: boolean
    xAxisData?: string[]
}

const props = withDefaults(defineProps<Props>(), {
    height: 300,
    title: '',
    horizontal: false,
})

const $q = useQuasar()
const isDark = computed(() => $q.dark.isActive)

const colors = [
    '#1E88E5',
    '#F57C00',
    '#43A047',
    '#E91E63',
    '#9C27B0',
    '#00ACC1',
    '#FDD835',
    '#E53935',
    '#5E35B1',
    '#00897B',
]

const chartOption = computed(() => {
    const textColor = isDark.value ? '#E0E0E0' : '#424242'
    const backgroundColor = 'transparent'
    const gridColor = isDark.value ? '#424242' : '#E0E0E0'

    const baseOption = {
        backgroundColor,
        textStyle: {
            color: textColor,
        },
        tooltip: {
            trigger: props.type === 'pie' ? 'item' : 'axis',
            backgroundColor: isDark.value ? '#424242' : '#FFFFFF',
            borderColor: isDark.value ? '#616161' : '#E0E0E0',
            textStyle: {
                color: textColor,
            },
        },
        color: colors,
    }

    if (props.type === 'line') {
        const xAxisLabels = computed(() => {
            if (props.xAxisData && props.xAxisData.length > 0) {
                return props.xAxisData;
            }
            const length = props.data[0]?.data?.length || 24;
            return Array.from({ length }, (_, i) => {
                const date = new Date();
                date.setHours(date.getHours() - length + i);
                return date.toLocaleTimeString('en-US', {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                });
            });
        });

        return {
            ...baseOption,
            grid: {
                left: '3%',
                right: '4%',
                bottom: '10%',
                top: '15%',
                containLabel: true,
            },
            xAxis: {
                type: 'category',
                boundaryGap: false,
                data: xAxisLabels.value,
                axisLine: {
                    lineStyle: { color: gridColor },
                },
                axisLabel: {
                    color: textColor,
                    rotate: 45,
                },
            },
            yAxis: {
                type: 'value',
                axisLine: {
                    lineStyle: { color: gridColor },
                },
                splitLine: {
                    lineStyle: { color: gridColor, type: 'dashed' },
                },
                axisLabel: {
                    color: textColor,
                },
            },
            legend: {
                show: false, // Legend is handled by the parent component
            },
            series: props.data.map((item) => ({
                name: item.name,
                type: 'line',
                smooth: true,
                data: item.data,
                emphasis: {
                    focus: 'series',
                },
                lineStyle: {
                    width: 2,
                    color: item.color,
                },
                itemStyle: {
                    color: item.color,
                },
            })),
        }
    }

    if (props.type === 'pie') {
        return {
            ...baseOption,
            tooltip: {
                ...baseOption.tooltip,
                formatter: '{b}: {c} ({d}%)',
            },
            legend: {
                orient: 'vertical',
                right: 10,
                top: 'center',
                textStyle: { color: textColor },
            },
            series: [
                {
                    type: 'pie',
                    radius: ['40%', '70%'],
                    avoidLabelOverlap: true,
                    itemStyle: {
                        borderRadius: 8,
                        borderColor: backgroundColor,
                        borderWidth: 2,
                    },
                    label: {
                        show: true,
                        position: 'outside',
                        formatter: '{b}\n{d}%',
                        color: textColor,
                    },
                    emphasis: {
                        label: {
                            show: true,
                            fontSize: 14,
                            fontWeight: 'bold',
                        },
                    },
                    data: props.data.map((item) => ({
                        value: item.value,
                        name: item.name,
                    })),
                },
            ],
        }
    }

    if (props.type === 'bar') {
        const isHorizontal = props.horizontal

        return {
            ...baseOption,
            grid: {
                left: isHorizontal ? '25%' : '3%',
                right: '4%',
                bottom: '10%',
                top: '10%',
                containLabel: !isHorizontal,
            },
            xAxis: {
                type: isHorizontal ? 'value' : 'category',
                data: isHorizontal ? undefined : props.data.map((item) => item.name),
                axisLine: {
                    lineStyle: { color: gridColor },
                },
                axisLabel: {
                    color: textColor,
                    rotate: isHorizontal ? 0 : 45,
                    interval: 0,
                },
                splitLine: isHorizontal
                    ? {
                        lineStyle: { color: gridColor, type: 'dashed' },
                    }
                    : undefined,
            },
            yAxis: {
                type: isHorizontal ? 'category' : 'value',
                data: isHorizontal ? props.data.map((item) => item.name) : undefined,
                inverse: isHorizontal,
                axisLine: {
                    lineStyle: { color: gridColor },
                },
                axisLabel: {
                    color: textColor,
                    formatter: isHorizontal ? (value: string) => {
                        return value.length > 30 ? value.substring(0, 30) + '...' : value
                    } : undefined,
                },
                splitLine: !isHorizontal
                    ? {
                        lineStyle: { color: gridColor, type: 'dashed' },
                    }
                    : undefined,
            },
            series: [
                {
                    type: 'bar',
                    data: props.data.map((item) => item.value),
                    itemStyle: {
                        borderRadius: isHorizontal ? [0, 4, 4, 0] : [4, 4, 0, 0],
                    },
                    emphasis: {
                        itemStyle: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)',
                        },
                    },
                },
            ],
        }
    }

    return baseOption
})
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