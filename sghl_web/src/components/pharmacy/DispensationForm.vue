<script setup>
import { ref, computed } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { useBatches } from '@/controllers/usePharmacy'

const props = defineProps({
  prescriptionId: { type: String, default: '' },
  prescriptionItems: { type: Array, default: () => [] },
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['submit', 'cancel'])

const localPrescriptionId = ref(props.prescriptionId || '')
const notes = ref('')
const selectedMedId = ref(null)
const { batches, loading: batchesLoading } = useBatches(selectedMedId)

// One dispensation item per prescription item
const items = ref(
  props.prescriptionItems.map((pi) => ({
    prescription_item_id: pi.id,
    batch_id: '',
    quantity: pi.quantity || 1,
    _medication: pi.medication_name || pi.medication || '',
  })),
)

const availableBatches = computed(() => {
  const list = batches.value?.results || batches.value || []
  return list.filter((b) => !b.is_expired && b.quantity > 0)
})

function handleSubmit() {
  emit('submit', {
    prescription_id: localPrescriptionId.value || props.prescriptionId,
    notes: notes.value,
    items: items.value
      .filter((i) => i.batch_id)
      .map(({ prescription_item_id, batch_id, quantity }) => ({
        prescription_item_id,
        batch_id,
        quantity: parseInt(quantity),
      })),
  })
}
</script>

<template>
  <div class="space-y-5">
    <AppAlert v-if="error" type="error" :message="error" />

    <div v-if="!props.prescriptionId">
      <label class="text-sm font-medium text-gray-700 block mb-1">
        ID Prescription <span class="text-red-500">*</span>
      </label>
      <input
        v-model="localPrescriptionId"
        type="text"
        placeholder="UUID de la prescription"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      />
    </div>

    <!-- Items -->
    <div v-if="items.length">
      <h4 class="text-sm font-semibold text-gray-700 mb-2">Articles à dispenser</h4>
      <div class="space-y-3">
        <div
          v-for="(item, i) in items"
          :key="item.prescription_item_id"
          class="bg-gray-50 rounded-lg border border-gray-200 p-3 space-y-2"
        >
          <p class="text-sm font-medium text-gray-800">{{ item._medication || `Article ${i + 1}` }}</p>
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="text-xs font-medium text-gray-600 block mb-1">
                Lot <span class="text-red-500">*</span>
              </label>
              <input
                v-model="item.batch_id"
                type="text"
                placeholder="UUID du lot"
                class="w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
              />
            </div>
            <div>
              <label class="text-xs font-medium text-gray-600 block mb-1">Quantité</label>
              <input
                v-model="item.quantity"
                type="number"
                min="1"
                class="w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Manual entry when no prescription items provided -->
    <div v-else class="text-sm text-gray-500 bg-gray-50 rounded-lg p-3">
      Aucun article de prescription — saisie manuelle via ID lot ci-dessus.
    </div>

    <div>
      <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
      <textarea
        v-model="notes"
        rows="2"
        placeholder="Observations, substitutions éventuelles…"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
      />
    </div>

    <div class="flex justify-end gap-3">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton :loading="loading" @click="handleSubmit">Valider la dispensation</AppButton>
    </div>
  </div>
</template>
