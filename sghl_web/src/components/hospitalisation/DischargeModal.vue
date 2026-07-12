<script setup>
import { ref } from 'vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'

const props = defineProps({
  open: Boolean,
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['close', 'submit'])

const form = ref({
  discharge_date: new Date().toISOString().slice(0, 16),
  discharge_type: 'NORMAL',
  discharge_notes: '',
})

const DISCHARGE_TYPES = [
  { value: 'NORMAL', label: 'Sortie normale' },
  { value: 'AGAINST_MEDICAL_ADVICE', label: 'Contre avis médical' },
  { value: 'TRANSFERRED', label: 'Transfert' },
  { value: 'DECEASED', label: 'Décès' },
]

function handleSubmit() {
  emit('submit', { ...form.value })
}
</script>

<template>
  <AppModal :open="open" title="Enregistrer la sortie" size="md" @close="emit('close')">
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <AppAlert v-if="error" type="error" :message="error" />

      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">
          Date et heure de sortie <span class="text-red-500">*</span>
        </label>
        <input
          v-model="form.discharge_date"
          type="datetime-local"
          required
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>

      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">
          Type de sortie <span class="text-red-500">*</span>
        </label>
        <select
          v-model="form.discharge_type"
          required
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        >
          <option v-for="t in DISCHARGE_TYPES" :key="t.value" :value="t.value">
            {{ t.label }}
          </option>
        </select>
      </div>

      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">Notes de sortie</label>
        <textarea
          v-model="form.discharge_notes"
          rows="3"
          placeholder="Résumé de séjour, instructions post-hospitalisation…"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
        />
      </div>
    </form>

    <template #footer>
      <AppButton variant="secondary" @click="emit('close')">Annuler</AppButton>
      <AppButton variant="danger" :loading="loading" @click="handleSubmit">
        Confirmer la sortie
      </AppButton>
    </template>
  </AppModal>
</template>
