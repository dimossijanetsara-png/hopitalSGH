<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'

const props = defineProps({ loading: Boolean, error: String })
const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  recorded_at: new Date().toISOString().slice(0, 16),
  temperature: '',
  systolic_bp: '',
  diastolic_bp: '',
  heart_rate: '',
  respiratory_rate: '',
  oxygen_saturation: '',
  weight: '',
  height: '',
  pain_score: '',
  notes: '',
})

function handleSubmit() {
  const payload = { recorded_at: form.value.recorded_at, notes: form.value.notes }
  const numericFields = [
    'temperature', 'systolic_bp', 'diastolic_bp', 'heart_rate',
    'respiratory_rate', 'oxygen_saturation', 'weight', 'height', 'pain_score',
  ]
  numericFields.forEach((k) => {
    if (form.value[k] !== '') payload[k] = form.value[k]
  })
  emit('submit', payload)
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-5">
    <AppAlert v-if="error" type="error" :message="error" />

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-gray-700">
        Date et heure <span class="text-red-500">*</span>
      </label>
      <input
        v-model="form.recorded_at"
        type="datetime-local"
        required
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      />
    </div>

    <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Température (°C)</label>
        <input v-model="form.temperature" type="number" step="0.1" min="30" max="45"
          placeholder="36.5"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">FC (bpm)</label>
        <input v-model="form.heart_rate" type="number" min="0" max="300" placeholder="75"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">PA syst. (mmHg)</label>
        <input v-model="form.systolic_bp" type="number" min="0" max="300" placeholder="120"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">PA diast. (mmHg)</label>
        <input v-model="form.diastolic_bp" type="number" min="0" max="200" placeholder="80"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">FR (/min)</label>
        <input v-model="form.respiratory_rate" type="number" min="0" max="60" placeholder="16"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">SpO₂ (%)</label>
        <input v-model="form.oxygen_saturation" type="number" step="0.1" min="0" max="100" placeholder="98"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Poids (kg)</label>
        <input v-model="form.weight" type="number" step="0.1" min="0" placeholder="70"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Taille (cm)</label>
        <input v-model="form.height" type="number" step="0.1" min="0" placeholder="170"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Douleur (0-10)</label>
        <input v-model="form.pain_score" type="number" min="0" max="10" placeholder="0"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-gray-700">Observations</label>
      <textarea
        v-model="form.notes"
        rows="2"
        placeholder="Remarques complémentaires…"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
      />
    </div>

    <div class="flex justify-end gap-3">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton type="submit" :loading="loading">Enregistrer</AppButton>
    </div>
  </form>
</template>
