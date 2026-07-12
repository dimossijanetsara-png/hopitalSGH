<script setup>
import { computed } from 'vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { VITAL_FIELDS, vitalAlertLevel } from '@/models/nursing.model'

const props = defineProps({
  vitals: { type: Array, default: () => [] },
  loading: Boolean,
})

const latest = computed(() => props.vitals[0] || null)

function formatTime(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', {
    day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
  })
}

function alertClass(key, value) {
  const level = vitalAlertLevel(key, value)
  if (level === 'danger') return 'text-red-600 font-bold'
  if (level === 'warning') return 'text-orange-500 font-semibold'
  return 'text-gray-900'
}
</script>

<template>
  <div>
    <!-- Latest vitals summary -->
    <div v-if="loading" class="flex justify-center py-8"><AppSpinner /></div>
    <div v-else-if="!vitals.length" class="text-center py-8 text-gray-400 text-sm">
      Aucune constante enregistrée
    </div>
    <div v-else>
      <!-- Summary cards for latest reading -->
      <div class="mb-4">
        <p class="text-xs text-gray-400 mb-2">Dernière prise : {{ formatTime(latest.recorded_at) }}</p>
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2">
          <div
            v-for="field in VITAL_FIELDS"
            :key="field.key"
            v-show="latest[field.key] !== null && latest[field.key] !== undefined"
            class="bg-white rounded-lg border border-gray-200 p-3"
          >
            <p class="text-xs text-gray-500 mb-0.5">{{ field.label }}</p>
            <p :class="['text-lg font-semibold', alertClass(field.key, latest[field.key])]">
              {{ latest[field.key] ?? '–' }}
              <span class="text-xs font-normal text-gray-400">{{ field.unit }}</span>
            </p>
          </div>
        </div>
      </div>

      <!-- History table -->
      <div class="bg-white rounded-xl border border-gray-200 overflow-auto">
        <table class="w-full text-xs min-w-[600px]">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-3 py-2 font-medium text-gray-600">Date</th>
              <th v-for="f in VITAL_FIELDS" :key="f.key" class="text-right px-2 py-2 font-medium text-gray-600 whitespace-nowrap">
                {{ f.label }}
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="v in vitals" :key="v.id" class="hover:bg-gray-50">
              <td class="px-3 py-2 text-gray-600 whitespace-nowrap">{{ formatTime(v.recorded_at) }}</td>
              <td
                v-for="f in VITAL_FIELDS"
                :key="f.key"
                class="px-2 py-2 text-right"
                :class="alertClass(f.key, v[f.key])"
              >
                {{ v[f.key] !== null && v[f.key] !== undefined ? `${v[f.key]} ${f.unit}` : '–' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
