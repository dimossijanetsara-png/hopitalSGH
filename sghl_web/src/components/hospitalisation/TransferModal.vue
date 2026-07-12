<script setup>
import { ref } from 'vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import BedMap from './BedMap.vue'
import { useAvailableBeds } from '@/controllers/useHospitalisation'

const props = defineProps({
  open: Boolean,
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['close', 'submit'])

const form = ref({
  new_bed: '',
  reason: '',
})

const selectedDepartmentId = ref(null)
const { beds, loading: bedsLoading } = useAvailableBeds(selectedDepartmentId)

function selectBed(bed) {
  form.value.new_bed = bed.id
}

function handleSubmit() {
  emit('submit', { ...form.value })
}
</script>

<template>
  <AppModal :open="open" title="Transférer le patient" size="lg" @close="emit('close')">
    <div class="space-y-4">
      <AppAlert v-if="error" type="error" :message="error" />

      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">
          Motif du transfert <span class="text-red-500">*</span>
        </label>
        <input
          v-model="form.reason"
          type="text"
          required
          placeholder="Raison du changement de lit / service…"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>

      <div>
        <div class="flex items-center justify-between mb-2">
          <label class="text-sm font-medium text-gray-700">
            Nouveau lit <span class="text-red-500">*</span>
          </label>
          <div class="flex items-center gap-2">
            <span class="text-xs text-gray-500">Filtrer par service :</span>
            <input
              v-model="selectedDepartmentId"
              type="text"
              placeholder="ID service"
              class="text-xs px-2 py-1 rounded border border-gray-300 w-28 focus:outline-none"
            />
          </div>
        </div>

        <div v-if="form.new_bed" class="mb-2 text-xs text-green-700 font-medium flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          Lit sélectionné : {{ form.new_bed }}
        </div>

        <div class="p-3 rounded-lg border border-gray-200 bg-gray-50">
          <BedMap
            :beds="beds || []"
            :loading="bedsLoading"
            :selectable="true"
            :selected-id="form.new_bed"
            @select="selectBed"
          />
        </div>
      </div>
    </div>

    <template #footer>
      <AppButton variant="secondary" @click="emit('close')">Annuler</AppButton>
      <AppButton :loading="loading" :disabled="!form.new_bed" @click="handleSubmit">
        Confirmer le transfert
      </AppButton>
    </template>
  </AppModal>
</template>
