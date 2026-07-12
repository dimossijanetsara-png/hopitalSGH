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
  const monthly = props.stats?.monthly || []
  return {
    labels: monthly.map((m) => m.label || m.month),
    datasets: [
      {
        label: 'Facturé',
        data: monthly.map((m) => m.invoiced ?? 0),
        backgroundColor: 'rgba(37, 99, 235, 0.7)',
        borderRadius: 4,
      },
      {
        label: 'Encaissé',
        data: monthly.map((m) => m.collected ?? 0),
        backgroundColor: 'rgba(20, 184, 166, 0.7)',
        borderRadius: 4,
      },
    ],
  }
})

const options = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'top', labels: { boxWidth: 12, font: { size: 11 } } },
    tooltip: {
      callbacks: {
        label: (ctx) =>
          ` ${ctx.dataset.label}: ${new Intl.NumberFormat('fr-FR').format(ctx.raw)} FCFA`,
      },
    },
  },
  scales: {
    y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { precision: 0 } },
    x: { grid: { display: false } },
  },
}
</script>

<template>
  <div class="bg-white rounded-xl border border-gray-200 p-5">
    <h3 class="text-sm font-semibold text-gray-700 mb-4">Revenus mensuels (FCFA)</h3>
    <div v-if="!stats?.monthly?.length" class="flex items-center justify-center h-40 text-gray-400 text-sm">
      Aucune donnée disponible
    </div>
    <div v-else class="h-52">
      <Bar :data="chartData" :options="options" />
    </div>
  </div>
</template>
