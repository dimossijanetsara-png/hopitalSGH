<script setup>
import { computed } from 'vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { BED_STATUS_BG, BED_STATUS_COLORS } from '@/models/hospitalisation.model'

const props = defineProps({
  beds: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  selectable: { type: Boolean, default: false },
  selectedId: { type: String, default: null },
})

const emit = defineEmits(['select'])

const stats = computed(() => ({
  available: props.beds.filter((b) => b.status === 'AVAILABLE').length,
  occupied: props.beds.filter((b) => b.status === 'OCCUPIED').length,
  maintenance: props.beds.filter((b) => b.status === 'MAINTENANCE').length,
  reserved: props.beds.filter((b) => b.status === 'RESERVED').length,
}))

const occupancyRate = computed(() => {
  if (!props.beds.length) return 0
  return Math.round((stats.value.occupied / props.beds.length) * 100)
})

function selectBed(bed) {
  if (!props.selectable || bed.status !== 'AVAILABLE') return
  emit('select', bed)
}
</script>

<template>
  <div>
    <!-- Stats bar -->
    <div class="flex flex-wrap gap-3 mb-4">
      <div class="flex items-center gap-1.5 text-sm">
        <span class="w-3 h-3 rounded-sm bg-green-400 inline-block"></span>
        <span class="text-gray-600">Disponible ({{ stats.available }})</span>
      </div>
      <div class="flex items-center gap-1.5 text-sm">
        <span class="w-3 h-3 rounded-sm bg-red-400 inline-block"></span>
        <span class="text-gray-600">Occupé ({{ stats.occupied }})</span>
      </div>
      <div class="flex items-center gap-1.5 text-sm">
        <span class="w-3 h-3 rounded-sm bg-yellow-400 inline-block"></span>
        <span class="text-gray-600">Maintenance ({{ stats.maintenance }})</span>
      </div>
      <div class="flex items-center gap-1.5 text-sm">
        <span class="w-3 h-3 rounded-sm bg-blue-400 inline-block"></span>
        <span class="text-gray-600">Réservé ({{ stats.reserved }})</span>
      </div>
      <div class="ml-auto text-sm font-medium text-gray-700">
        Taux d'occupation : <span :class="occupancyRate >= 90 ? 'text-red-600' : occupancyRate >= 75 ? 'text-orange-500' : 'text-green-600'">{{ occupancyRate }}%</span>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12">
      <AppSpinner size="lg" />
    </div>

    <!-- Empty -->
    <div v-else-if="!beds.length" class="text-center py-12 text-gray-400">
      <svg class="w-12 h-12 mx-auto mb-2 opacity-40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 7h18M3 12h18M3 17h18" />
      </svg>
      <p>Aucun lit dans cette chambre</p>
    </div>

    <!-- Grid -->
    <div v-else class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-2">
      <button
        v-for="bed in beds"
        :key="bed.id"
        :disabled="selectable && bed.status !== 'AVAILABLE'"
        :class="[
          'relative flex flex-col items-center justify-center p-3 rounded-lg border-2 transition-all text-xs font-medium',
          BED_STATUS_BG[bed.status] || 'bg-gray-100 border-gray-200 text-gray-700',
          selectable && bed.status === 'AVAILABLE' ? 'cursor-pointer hover:scale-105 hover:shadow-md' : 'cursor-default',
          selectable && selectedId === bed.id ? 'ring-2 ring-offset-1 ring-blue-500' : '',
          selectable && bed.status !== 'AVAILABLE' ? 'opacity-60' : '',
        ]"
        @click="selectBed(bed)"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 7h18M3 12h18M3 17h6" />
        </svg>
        <span>{{ bed.number || bed.id?.slice(0, 4) }}</span>
      </button>
    </div>
  </div>
</template>
