<script setup>
import { computed } from 'vue'

const props = defineProps({
  occupied: { type: Number, default: 0 },
  total: { type: Number, default: 0 },
})

const rate = computed(() => (props.total > 0 ? Math.round((props.occupied / props.total) * 100) : 0))
const circumference = 2 * Math.PI * 40
const dashOffset = computed(() => circumference - (rate.value / 100) * circumference)
const color = computed(() => {
  if (rate.value >= 90) return '#dc2626'
  if (rate.value >= 75) return '#d97706'
  return '#16a34a'
})
</script>

<template>
  <div class="flex flex-col items-center gap-2">
    <svg width="100" height="100" viewBox="0 0 100 100">
      <circle cx="50" cy="50" r="40" fill="none" stroke="#e5e7eb" stroke-width="10" />
      <circle
        cx="50" cy="50" r="40" fill="none"
        :stroke="color" stroke-width="10"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        transform="rotate(-90 50 50)"
        style="transition: stroke-dashoffset 0.6s ease"
      />
      <text x="50" y="55" text-anchor="middle" font-size="18" font-weight="bold" :fill="color">
        {{ rate }}%
      </text>
    </svg>
    <p class="text-xs text-gray-500 text-center">
      {{ occupied }} / {{ total }} lits occupés
    </p>
  </div>
</template>
