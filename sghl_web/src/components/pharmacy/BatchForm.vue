<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'

const props = defineProps({
  medicationId: { type: String, default: '' },
  loading: Boolean,
  error: String,
})
const emit = defineEmits(['submit', 'cancel'])

const form = ref({
  medication_id: props.medicationId || '',
  batch_number: '',
  quantity: '',
  expiry_date: '',
  supplier: '',
  purchase_price: '',
  received_at: new Date().toISOString().slice(0, 16),
})

function handleSubmit() {
  emit('submit', {
    ...form.value,
    quantity: parseInt(form.value.quantity),
    purchase_price: form.value.purchase_price ? parseFloat(form.value.purchase_price) : 0,
  })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <AppAlert v-if="error" type="error" :message="error" />

    <div v-if="!medicationId">
      <AppInput v-model="form.medication_id" label="ID Médicament" required placeholder="UUID" />
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <AppInput v-model="form.batch_number" label="Numéro de lot" required placeholder="LOT-2025-001" />
      <AppInput v-model="form.quantity" label="Quantité reçue" type="number" required placeholder="100" />
      <AppInput v-model="form.expiry_date" label="Date de péremption" type="date" required />
      <AppInput v-model="form.received_at" label="Date de réception" type="datetime-local" required />
      <AppInput v-model="form.supplier" label="Fournisseur" placeholder="Nom du fournisseur" />
      <AppInput v-model="form.purchase_price" label="Prix d'achat unitaire" type="number" step="0.01" placeholder="0.00" />
    </div>

    <div class="flex justify-end gap-3 pt-2">
      <AppButton variant="secondary" type="button" @click="emit('cancel')">Annuler</AppButton>
      <AppButton type="submit" :loading="loading">Enregistrer la réception</AppButton>
    </div>
  </form>
</template>
