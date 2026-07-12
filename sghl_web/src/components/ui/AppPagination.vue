<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentPage: { type: Number, default: 1 },
  totalPages: { type: Number, default: 1 },
  totalItems: { type: Number, default: 0 },
  pageSize: { type: Number, default: 20 },
})
const emit = defineEmits(['change'])

const pages = computed(() => {
  const range = []
  const delta = 2
  for (
    let i = Math.max(1, props.currentPage - delta);
    i <= Math.min(props.totalPages, props.currentPage + delta);
    i++
  ) {
    range.push(i)
  }
  return range
})
</script>

<template>
  <div v-if="totalPages > 1" class="flex items-center justify-between text-sm text-gray-600 mt-4">
    <span class="text-xs text-gray-400">
      {{ (currentPage - 1) * pageSize + 1 }}–{{ Math.min(currentPage * pageSize, totalItems) }}
      sur {{ totalItems }} résultats
    </span>
    <div class="flex items-center gap-1">
      <button
        :disabled="currentPage === 1"
        @click="emit('change', currentPage - 1)"
        class="px-2 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-100 disabled:opacity-40 disabled:cursor-not-allowed"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
      </button>
      <button
        v-for="p in pages"
        :key="p"
        @click="emit('change', p)"
        :class="[
          'w-8 h-8 rounded-lg text-sm font-medium transition-colors',
          p === currentPage
            ? 'bg-blue-700 text-white'
            : 'border border-gray-200 hover:bg-gray-100 text-gray-700',
        ]"
      >
        {{ p }}
      </button>
      <button
        :disabled="currentPage === totalPages"
        @click="emit('change', currentPage + 1)"
        class="px-2 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-100 disabled:opacity-40 disabled:cursor-not-allowed"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </button>
    </div>
  </div>
</template>
