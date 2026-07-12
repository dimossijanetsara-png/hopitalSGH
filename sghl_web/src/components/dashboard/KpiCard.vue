<script setup>
import { KPI_COLOR_CLASSES } from '@/models/dashboard.model'

defineProps({
  label: String,
  value: [String, Number],
  icon: String,
  color: { type: String, default: 'blue' },
  sub: { type: String, default: '' },
  loading: { type: Boolean, default: false },
})
</script>

<template>
  <div :class="['rounded-xl border border-gray-200 bg-white p-5 flex items-start gap-4']">
    <div :class="['w-11 h-11 rounded-lg flex items-center justify-center shrink-0', KPI_COLOR_CLASSES[color].icon]">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="icon" />
      </svg>
    </div>
    <div class="flex-1 min-w-0">
      <p class="text-xs font-medium text-gray-500 uppercase tracking-wide truncate">{{ label }}</p>
      <div v-if="loading" class="mt-1 h-7 w-24 bg-gray-100 rounded animate-pulse" />
      <p v-else :class="['text-2xl font-bold mt-0.5', KPI_COLOR_CLASSES[color].value]">{{ value }}</p>
      <p v-if="sub" class="text-xs text-gray-400 mt-0.5">{{ sub }}</p>
    </div>
  </div>
</template>
