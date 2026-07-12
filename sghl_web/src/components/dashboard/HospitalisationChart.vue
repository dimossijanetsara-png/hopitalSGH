<script setup>
import { computed } from 'vue'
import { Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale, LinearScale, BarElement,
  Title, Tooltip, Legend,
} from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

const props = defineProps({
  stats: { type: Object, default: () => ({}) },
})

const chartData = computed(() => {
  const byService = props.stats?.by_department || {}
  const labels = Object.keys(byService)
  const values = Object.values(byService)
  return {
    labels,
    datasets: [
      {
        label: 'Admissions actives',
        data: values,
        backgroundColor: 'rgba(37, 99, 235, 0.8)',
        borderColor: 'rgba(37, 99, 235, 1)',
        borderWidth: 1,
        borderRadius: 6,
      },
    ],
  }
})

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: { callbacks: { label: (ctx) => ` ${ctx.raw} patients` } },
  },
  scales: {
    y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { precision: 0 } },
    x: { grid: { display: false } },
  },
}
</script>

<template>
  <div class="bg-white rounded-xl border border-gray-200 p-5">
    <h3 class="text-sm font-semibold text-gray-700 mb-4">Hospitalisations par service</h3>
    <div v-if="!Object.keys(stats?.by_department || {}).length" class="flex items-center justify-center h-40 text-gray-400 text-sm">
      Aucune donnée disponible
    </div>
    <div v-else class="h-52">
      <Bar :data="chartData" :options="options" />
    </div>
  </div>
</template>
