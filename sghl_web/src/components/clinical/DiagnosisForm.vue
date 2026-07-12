<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { DIAG_TYPES, COMMON_ICD10 } from '@/models/clinical.model'
import { useAddDiagnosis } from '@/controllers/useClinical'

const props = defineProps({ consultationId: { type: String, required: true } })
const emit = defineEmits(['added'])

const { submit, loading, error } = useAddDiagnosis(props.consultationId)

const form = ref({ icd10_code: '', icd10_label: '', diag_type: 'PRINCIPAL', notes: '' })
const showSuggestions = ref(false)

const filtered = ref([])
function onCodeInput() {
  const q = form.value.icd10_code.toLowerCase()
  filtered.value = q
    ? COMMON_ICD10.filter(
        (c) => c.code.toLowerCase().includes(q) || c.label.toLowerCase().includes(q),
      ).slice(0, 6)
    : []
  showSuggestions.value = filtered.value.length > 0
}

function selectSuggestion(item) {
  form.value.icd10_code = item.code
  form.value.icd10_label = item.label
  showSuggestions.value = false
}

function handleSubmit() {
  submit(form.value, {
    onSuccess: () => {
      emit('added')
      form.value = { icd10_code: '', icd10_label: '', diag_type: 'PRINCIPAL', notes: '' }
    },
  })
}
</script>

<template>
  <div class="bg-gray-50 rounded-xl border border-gray-200 p-4">
    <h4 class="text-sm font-semibold text-gray-700 mb-3">Ajouter un diagnostic</h4>
    <AppAlert v-if="error" type="error" :message="error" class="mb-3" />

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
      <!-- Code CIM-10 avec autocomplete -->
      <div class="relative flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Code CIM-10 <span class="text-red-500">*</span></label>
        <input
          v-model="form.icd10_code"
          @input="onCodeInput"
          @blur="setTimeout(() => showSuggestions = false, 200)"
          type="text"
          placeholder="Ex. J06.9"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
        <div
          v-if="showSuggestions"
          class="absolute top-full mt-1 left-0 right-0 bg-white border border-gray-200 rounded-lg shadow-lg z-10 overflow-hidden"
        >
          <button
            v-for="item in filtered"
            :key="item.code"
            type="button"
            @mousedown.prevent="selectSuggestion(item)"
            class="flex flex-col px-3 py-2 w-full text-left hover:bg-blue-50 border-b border-gray-100 last:border-0"
          >
            <span class="text-xs font-bold text-blue-700">{{ item.code }}</span>
            <span class="text-xs text-gray-600 truncate">{{ item.label }}</span>
          </button>
        </div>
      </div>

      <!-- Libellé -->
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Libellé <span class="text-red-500">*</span></label>
        <input
          v-model="form.icd10_label"
          type="text"
          placeholder="Description du diagnostic"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>

      <!-- Type -->
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Type</label>
        <select
          v-model="form.diag_type"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        >
          <option v-for="t in DIAG_TYPES" :key="t.value" :value="t.value">{{ t.label }}</option>
        </select>
      </div>

      <!-- Notes -->
      <div class="flex flex-col gap-1">
        <label class="text-xs font-medium text-gray-600">Notes</label>
        <input
          v-model="form.notes"
          type="text"
          placeholder="Observations complémentaires"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>
    </div>

    <div class="flex justify-end mt-3">
      <AppButton size="sm" :loading="loading" @click="handleSubmit" :disabled="!form.icd10_code || !form.icd10_label">
        Ajouter le diagnostic
      </AppButton>
    </div>
  </div>
</template>
