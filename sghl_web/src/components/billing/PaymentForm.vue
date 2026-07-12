<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { PAYMENT_METHODS } from '@/models/billing.model'

const props = defineProps({
  balanceDue: { type: [Number, String], default: 0 },
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  amount: props.balanceDue ? parseFloat(props.balanceDue) : '',
  method: 'CASH',
  reference: '',
  notes: '',
})

function handleSubmit() {
  emit('submit', {
    amount: parseFloat(form.value.amount),
    method: form.value.method,
    reference: form.value.reference,
    notes: form.value.notes,
  })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <AppAlert v-if="error" type="error" :message="error" />

    <div>
      <label class="text-sm font-medium text-gray-700 block mb-1">
        Montant (F) <span class="text-red-500">*</span>
      </label>
      <input
        v-model="form.amount"
        type="number"
        step="0.01"
        min="0.01"
        required
        :placeholder="balanceDue ? `Solde restant : ${parseFloat(balanceDue).toLocaleString('fr-FR')} F` : 'Montant'"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      />
    </div>

    <div>
      <label class="text-sm font-medium text-gray-700 block mb-1">
        Mode de paiement <span class="text-red-500">*</span>
      </label>
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
        <label
          v-for="m in PAYMENT_METHODS"
          :key="m.value"
          :class="[
            'flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer text-sm transition-colors',
            form.method === m.value
              ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium'
              : 'border-gray-200 hover:border-gray-300',
          ]"
        >
          <input v-model="form.method" type="radio" :value="m.value" class="hidden" />
          {{ m.label }}
        </label>
      </div>
    </div>

    <div>
      <label class="text-sm font-medium text-gray-700 block mb-1">Référence</label>
      <input
        v-model="form.reference"
        type="text"
        placeholder="N° de reçu, transaction…"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      />
    </div>

    <div>
      <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
      <textarea
        v-model="form.notes"
        rows="2"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
      />
    </div>

    <div class="flex justify-end gap-3 pt-1">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton type="submit" :loading="loading" :disabled="!form.amount">
        Enregistrer le paiement
      </AppButton>
    </div>
  </form>
</template>
