<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useCreateConsultation } from '@/controllers/useClinical'
import { CONSULTATION_STATUSES } from '@/models/clinical.model'

const route = useRoute()
const { submit, loading, error } = useCreateConsultation()

const form = ref({
  patient: route.query.patient || '',
  consultation_date: new Date().toISOString().split('T')[0],
  status: 'SCHEDULED',
  chief_complaint: '',
  anamnesis: '',
  physical_exam: '',
  notes: '',
})

function handleSubmit() {
  submit(form.value)
}
</script>

<template>
  <DashboardLayout>
    <div class="max-w-2xl mx-auto">
      <div class="flex items-center gap-3 mb-6">
        <RouterLink to="/consultations" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </RouterLink>
        <h1 class="text-2xl font-bold text-gray-900">Nouvelle consultation</h1>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

        <form @submit.prevent="handleSubmit" class="space-y-5">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <AppInput
              v-model="form.patient"
              label="ID Patient"
              required
              placeholder="UUID du patient"
              :hint="$route.query.patient ? 'Patient pré-sélectionné' : ''"
            />
            <AppInput
              v-model="form.consultation_date"
              label="Date de consultation"
              type="date"
              required
            />
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Statut initial</label>
            <select
              v-model="form.status"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            >
              <option v-for="s in CONSULTATION_STATUSES" :key="s.value" :value="s.value">
                {{ s.label }}
              </option>
            </select>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">
              Motif de consultation <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.chief_complaint"
              type="text"
              required
              placeholder="Raison principale de la consultation"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Anamnèse</label>
            <textarea
              v-model="form.anamnesis"
              rows="4"
              placeholder="Histoire de la maladie, antécédents pertinents…"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
            />
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Examen physique</label>
            <textarea
              v-model="form.physical_exam"
              rows="4"
              placeholder="Résultats de l'examen clinique…"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
            />
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-gray-700">Notes complémentaires</label>
            <textarea
              v-model="form.notes"
              rows="3"
              placeholder="Observations, plan thérapeutique…"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
            />
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <RouterLink to="/consultations">
              <AppButton variant="secondary" type="button">Annuler</AppButton>
            </RouterLink>
            <AppButton type="submit" :loading="loading">Créer la consultation</AppButton>
          </div>
        </form>
      </div>
    </div>
  </DashboardLayout>
</template>
