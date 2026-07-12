<script setup>
import { ref, watch } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'

const props = defineProps({
  items: { type: Array, required: true },
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['submit', 'cancel'])

const results = ref([])

watch(
  () => props.items,
  (items) => {
    results.value = items.map((item) => ({
      item_id: item.id,
      result_value: item.result_value || '',
      result_unit: item.result_unit || item.test?.unit || '',
      is_abnormal: item.is_abnormal || false,
      notes: item.notes || '',
      _test_name: item.test?.name || item.test_id,
      _normal_range: item.test?.normal_range || '',
    }))
  },
  { immediate: true },
)

function handleSubmit() {
  emit(
    'submit',
    results.value.map(({ item_id, result_value, result_unit, is_abnormal, notes }) => ({
      item_id,
      result_value,
      result_unit,
      is_abnormal,
      notes,
    })),
  )
}
</script>

<template>
  <div class="space-y-4">
    <AppAlert v-if="error" type="error" :message="error" />

    <div
      v-for="(r, i) in results"
      :key="r.item_id"
      class="bg-gray-50 rounded-lg border border-gray-200 p-4"
    >
      <div class="flex items-center justify-between mb-3">
        <div>
          <p class="text-sm font-semibold text-gray-800">{{ r._test_name }}</p>
          <p v-if="r._normal_range" class="text-xs text-gray-400">Norme : {{ r._normal_range }}</p>
        </div>
        <label class="flex items-center gap-1.5 text-xs text-red-600 cursor-pointer">
          <input v-model="r.is_abnormal" type="checkbox" class="rounded" />
          Anormal
        </label>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="text-xs font-medium text-gray-600 block mb-1">
            Résultat <span class="text-red-500">*</span>
          </label>
          <input
            v-model="r.result_value"
            type="text"
            placeholder="Valeur"
            :class="[
              'w-full px-3 py-2 text-sm rounded-lg border focus:outline-none focus:ring-2',
              r.is_abnormal
                ? 'border-red-300 bg-red-50 focus:ring-red-200'
                : 'border-gray-300 focus:ring-blue-300',
            ]"
          />
        </div>
        <div>
          <label class="text-xs font-medium text-gray-600 block mb-1">Unité</label>
          <input
            v-model="r.result_unit"
            type="text"
            placeholder="g/L, mmol/L…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
          />
        </div>
      </div>

      <div class="mt-2">
        <label class="text-xs font-medium text-gray-600 block mb-1">Notes</label>
        <input
          v-model="r.notes"
          type="text"
          placeholder="Commentaire optionnel…"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>
    </div>

    <div class="flex justify-end gap-3 pt-2">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton :loading="loading" @click="handleSubmit">Enregistrer les résultats</AppButton>
    </div>
  </div>
</template>
