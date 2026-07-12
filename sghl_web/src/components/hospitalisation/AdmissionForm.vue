<script setup>
import { ref, watch } from 'vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import BedMap from './BedMap.vue'
import { useAvailableBeds } from '@/controllers/useHospitalisation'

const props = defineProps({
  loading: Boolean,
  error: String,
  patientId: { type: String, default: '' },
})

const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  patient: props.patientId || '',
  bed: '',
  admission_date: new Date().toISOString().slice(0, 16),
  reason: '',
  notes: '',
  treating_doctor: '',
})

watch(() => props.patientId, (v) => { form.value.patient = v || '' })

const selectedDepartmentId = ref(null)
const { beds, loading: bedsLoading } = useAvailableBeds(selectedDepartmentId)

function selectBed(bed) {
  form.value.bed = bed.id
}

function handleSubmit() {
  emit('submit', { ...form.value })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-5">
    <AppAlert v-if="error" type="error" :message="error" />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <AppInput
        v-model="form.patient"
        label="ID Patient"
        required
        placeholder="UUID du patient"
      />
      <AppInput
        v-model="form.admission_date"
        label="Date et heure d'admission"
        type="datetime-local"
        required
      />
    </div>

    <AppInput
      v-model="form.reason"
      label="Motif d'hospitalisation"
      required
      placeholder="Raison principale de l'hospitalisation"
    />

    <AppInput
      v-model="form.treating_doctor"
      label="Médecin traitant (ID)"
      placeholder="UUID du médecin (optionnel)"
    />

    <!-- Bed selection -->
    <div>
      <div class="flex items-center justify-between mb-2">
        <label class="text-sm font-medium text-gray-700">
          Sélection du lit <span class="text-red-500">*</span>
        </label>
        <div class="flex items-center gap-2">
          <label class="text-xs text-gray-500">Filtrer par service :</label>
          <input
            v-model="selectedDepartmentId"
            type="text"
            placeholder="ID service"
            class="text-xs px-2 py-1 rounded border border-gray-300 w-32 focus:outline-none focus:ring-1 focus:ring-blue-300"
          />
        </div>
      </div>

      <div v-if="form.bed" class="mb-2 text-xs text-green-700 font-medium flex items-center gap-1">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
        Lit sélectionné : {{ form.bed }}
      </div>

      <div class="p-3 rounded-lg border border-gray-200 bg-gray-50">
        <BedMap
          :beds="beds || []"
          :loading="bedsLoading"
          :selectable="true"
          :selected-id="form.bed"
          @select="selectBed"
        />
      </div>
      <input type="hidden" v-model="form.bed" required />
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-gray-700">Notes</label>
      <textarea
        v-model="form.notes"
        rows="3"
        placeholder="Observations complémentaires…"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
      />
    </div>

    <div class="flex justify-end gap-3 pt-2">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton type="submit" :loading="loading" :disabled="!form.bed">
        Créer l'admission
      </AppButton>
    </div>
  </form>
</template>
