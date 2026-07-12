<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { PRESCRIPTION_FREQUENCIES, PRESCRIPTION_ROUTES } from '@/models/clinical.model'
import { useCreatePrescription } from '@/controllers/useClinical'

const props = defineProps({ consultationId: { type: String, required: true } })
const emit = defineEmits(['created'])

const { submit, loading, error } = useCreatePrescription(props.consultationId)

const notes = ref('')
const items = ref([emptyItem()])

function emptyItem() {
  return {
    medication_name: '',
    dosage: '',
    frequency: '1x/jour',
    duration: '',
    route: 'PO',
    instructions: '',
    quantity: 1,
  }
}

function addItem() { items.value.push(emptyItem()) }
function removeItem(i) { if (items.value.length > 1) items.value.splice(i, 1) }

function handleSubmit() {
  submit(
    { notes: notes.value, items: items.value },
    {
      onSuccess: () => {
        emit('created')
        notes.value = ''
        items.value = [emptyItem()]
      },
    },
  )
}
</script>

<template>
  <div class="bg-gray-50 rounded-xl border border-gray-200 p-4">
    <h4 class="text-sm font-semibold text-gray-700 mb-3">Nouvelle ordonnance</h4>
    <AppAlert v-if="error" type="error" :message="error" class="mb-3" />

    <!-- Médicaments -->
    <div class="space-y-3 mb-3">
      <div
        v-for="(item, i) in items"
        :key="i"
        class="bg-white rounded-lg border border-gray-200 p-3"
      >
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs font-semibold text-blue-700">Médicament {{ i + 1 }}</span>
          <button
            v-if="items.length > 1"
            @click="removeItem(i)"
            class="text-red-400 hover:text-red-600"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
          <div class="col-span-2 sm:col-span-1 flex flex-col gap-1">
            <label class="text-xs text-gray-500">Médicament *</label>
            <input
              v-model="item.medication_name"
              placeholder="Ex. Amoxicilline"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs text-gray-500">Dosage *</label>
            <input
              v-model="item.dosage"
              placeholder="Ex. 500mg"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs text-gray-500">Fréquence</label>
            <select
              v-model="item.frequency"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            >
              <option v-for="f in PRESCRIPTION_FREQUENCIES" :key="f.value" :value="f.value">
                {{ f.label }}
              </option>
            </select>
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs text-gray-500">Durée</label>
            <input
              v-model="item.duration"
              placeholder="Ex. 7 jours"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs text-gray-500">Voie</label>
            <select
              v-model="item.route"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            >
              <option v-for="r in PRESCRIPTION_ROUTES" :key="r.value" :value="r.value">
                {{ r.label }}
              </option>
            </select>
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs text-gray-500">Quantité</label>
            <input
              v-model.number="item.quantity"
              type="number" min="1"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
          <div class="col-span-2 sm:col-span-3 flex flex-col gap-1">
            <label class="text-xs text-gray-500">Instructions spéciales</label>
            <input
              v-model="item.instructions"
              placeholder="Ex. À prendre pendant les repas"
              class="w-full px-2 py-1.5 text-xs rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-200"
            />
          </div>
        </div>
      </div>
    </div>

    <button
      type="button"
      @click="addItem"
      class="flex items-center gap-1.5 text-xs text-blue-600 hover:text-blue-800 mb-3"
    >
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
      Ajouter un médicament
    </button>

    <!-- Notes globales -->
    <div class="flex flex-col gap-1 mb-3">
      <label class="text-xs font-medium text-gray-600">Notes de l'ordonnance</label>
      <textarea
        v-model="notes"
        rows="2"
        placeholder="Instructions générales, contexte clinique…"
        class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
      />
    </div>

    <div class="flex justify-end">
      <AppButton size="sm" :loading="loading" @click="handleSubmit">
        Créer l'ordonnance
      </AppButton>
    </div>
  </div>
</template>
