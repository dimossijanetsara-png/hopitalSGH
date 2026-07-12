<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import DiagnosisForm from '@/components/clinical/DiagnosisForm.vue'
import PrescriptionForm from '@/components/clinical/PrescriptionForm.vue'
import PrescriptionCard from '@/components/clinical/PrescriptionCard.vue'
import {
  useConsultation,
  useUpdateConsultation,
} from '@/controllers/useClinical'
import {
  CONSULTATION_STATUSES,
  CONSULTATION_STATUS_COLORS,
  DIAG_TYPE_COLORS,
} from '@/models/clinical.model'
import { formatDate } from '@/models/patient.model'
import { useAuthStore } from '@/stores/auth.store'

const route = useRoute()
const id = route.params.id
const auth = useAuthStore()
const isDoctor = ['DOCTOR', 'ADMIN'].includes(auth.currentRole)

const { consultation, loading, refetch } = useConsultation(id)
const { submit: updateConsultation, loading: updating } = useUpdateConsultation(id)

const tab = ref('info')
const showDiagForm = ref(false)
const showPrescForm = ref(false)

const tabs = [
  { key: 'info', label: 'Informations cliniques' },
  { key: 'diagnostics', label: 'Diagnostics' },
  { key: 'prescriptions', label: 'Ordonnances' },
]

function changeStatus(newStatus) {
  updateConsultation({ status: newStatus })
}
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20">
      <AppSpinner size="lg" />
    </div>

    <div v-else-if="consultation">
      <!-- Header -->
      <div class="flex items-start justify-between mb-6">
        <div class="flex items-center gap-4">
          <RouterLink to="/consultations" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div>
            <div class="flex items-center gap-2 flex-wrap">
              <h1 class="text-xl font-bold text-gray-900">
                Consultation — {{ consultation.patient?.first_name }}
                {{ consultation.patient?.last_name }}
              </h1>
              <AppBadge
                :label="CONSULTATION_STATUSES.find((s) => s.value === consultation.status)?.label"
                :color="CONSULTATION_STATUS_COLORS[consultation.status]"
              />
            </div>
            <p class="text-sm text-gray-500 mt-0.5">
              Dr. {{ consultation.doctor?.first_name }} {{ consultation.doctor?.last_name }} ·
              {{ formatDate(consultation.consultation_date) }}
            </p>
          </div>
        </div>

        <!-- Actions statut -->
        <div v-if="isDoctor" class="flex gap-2">
          <AppButton
            v-if="consultation.status === 'SCHEDULED'"
            size="sm"
            variant="secondary"
            :loading="updating"
            @click="changeStatus('IN_PROGRESS')"
          >
            Démarrer
          </AppButton>
          <AppButton
            v-if="consultation.status === 'IN_PROGRESS'"
            size="sm"
            :loading="updating"
            @click="changeStatus('COMPLETED')"
          >
            Terminer
          </AppButton>
          <AppButton
            v-if="['SCHEDULED', 'IN_PROGRESS'].includes(consultation.status)"
            size="sm"
            variant="danger"
            :loading="updating"
            @click="changeStatus('CANCELLED')"
          >
            Annuler
          </AppButton>
        </div>
      </div>

      <!-- Tabs -->
      <div class="flex gap-1 mb-6 border-b border-gray-200">
        <button
          v-for="t in tabs"
          :key="t.key"
          @click="tab = t.key"
          :class="[
            'px-4 py-2.5 text-sm font-medium transition-colors border-b-2 -mb-px',
            tab === t.key
              ? 'border-blue-600 text-blue-700'
              : 'border-transparent text-gray-500 hover:text-gray-700',
          ]"
        >
          {{ t.label }}
          <span
            v-if="t.key === 'diagnostics'"
            class="ml-1.5 px-1.5 py-0.5 bg-gray-100 text-gray-600 rounded-full text-xs"
          >{{ consultation.diagnoses?.length ?? 0 }}</span>
          <span
            v-if="t.key === 'prescriptions'"
            class="ml-1.5 px-1.5 py-0.5 bg-gray-100 text-gray-600 rounded-full text-xs"
          >{{ consultation.prescriptions?.length ?? 0 }}</span>
        </button>
      </div>

      <!-- Tab: Informations cliniques -->
      <div v-if="tab === 'info'" class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="lg:col-span-2 space-y-4">
          <!-- Motif de consultation -->
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Motif de consultation</h3>
            <p class="text-sm text-gray-800 bg-blue-50 rounded-lg p-3">
              {{ consultation.chief_complaint || '—' }}
            </p>
          </div>

          <!-- Anamnèse -->
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Anamnèse</h3>
            <p class="text-sm text-gray-700 whitespace-pre-wrap">
              {{ consultation.anamnesis || 'Non renseignée.' }}
            </p>
          </div>

          <!-- Examen physique -->
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Examen physique</h3>
            <p class="text-sm text-gray-700 whitespace-pre-wrap">
              {{ consultation.physical_exam || 'Non renseigné.' }}
            </p>
          </div>

          <!-- Notes -->
          <div v-if="consultation.notes" class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Notes</h3>
            <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ consultation.notes }}</p>
          </div>
        </div>

        <!-- Sidebar: infos rapides -->
        <div class="space-y-4">
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Patient</h3>
            <RouterLink
              :to="`/patients/${consultation.patient?.id}`"
              class="flex items-center gap-3 p-2 rounded-lg hover:bg-blue-50 group"
            >
              <div class="w-9 h-9 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-sm">
                {{ consultation.patient?.first_name?.charAt(0) }}{{ consultation.patient?.last_name?.charAt(0) }}
              </div>
              <div>
                <p class="text-sm font-medium text-gray-900 group-hover:text-blue-700">
                  {{ consultation.patient?.first_name }} {{ consultation.patient?.last_name }}
                </p>
                <p class="text-xs text-gray-400 font-mono">{{ consultation.patient?.record_number }}</p>
              </div>
            </RouterLink>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 p-5 space-y-3 text-sm">
            <div>
              <p class="text-xs text-gray-400">Médecin référent</p>
              <p class="text-gray-900 font-medium">
                Dr. {{ consultation.doctor?.first_name }} {{ consultation.doctor?.last_name }}
              </p>
            </div>
            <div>
              <p class="text-xs text-gray-400">Date</p>
              <p class="text-gray-900">{{ formatDate(consultation.consultation_date) }}</p>
            </div>
            <div v-if="consultation.hospitalization">
              <p class="text-xs text-gray-400">Hospitalisation liée</p>
              <RouterLink
                :to="`/hospitalisation/${consultation.hospitalization}`"
                class="text-blue-600 text-xs hover:underline"
              >
                Voir l'hospitalisation →
              </RouterLink>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Diagnostics -->
      <div v-if="tab === 'diagnostics'" class="space-y-4">
        <!-- Liste diagnostics -->
        <div
          v-if="!consultation.diagnoses?.length"
          class="bg-white rounded-xl border border-dashed border-gray-300 p-10 text-center text-gray-400 text-sm"
        >
          Aucun diagnostic enregistré
        </div>
        <div v-else class="space-y-2">
          <div
            v-for="diag in consultation.diagnoses"
            :key="diag.id"
            class="bg-white rounded-xl border border-gray-200 p-4 flex items-start gap-4"
          >
            <div class="w-10 h-10 rounded-lg bg-red-50 flex items-center justify-center shrink-0">
              <span class="text-xs font-bold text-red-700">{{ diag.icd10_code }}</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center gap-2 flex-wrap">
                <p class="text-sm font-semibold text-gray-900">{{ diag.icd10_label }}</p>
                <AppBadge
                  :label="diag.diag_type"
                  :color="DIAG_TYPE_COLORS[diag.diag_type]"
                />
              </div>
              <p v-if="diag.notes" class="text-xs text-gray-500 mt-1">{{ diag.notes }}</p>
            </div>
          </div>
        </div>

        <!-- Formulaire ajout diagnostic -->
        <DiagnosisForm
          v-if="isDoctor && ['SCHEDULED', 'IN_PROGRESS'].includes(consultation.status)"
          :consultation-id="id"
          @added="refetch"
        />
      </div>

      <!-- Tab: Ordonnances -->
      <div v-if="tab === 'prescriptions'" class="space-y-4">
        <div
          v-if="!consultation.prescriptions?.length"
          class="bg-white rounded-xl border border-dashed border-gray-300 p-10 text-center text-gray-400 text-sm"
        >
          Aucune ordonnance
        </div>
        <PrescriptionCard
          v-for="presc in consultation.prescriptions"
          :key="presc.id"
          :prescription="presc"
        />

        <PrescriptionForm
          v-if="isDoctor && ['SCHEDULED', 'IN_PROGRESS'].includes(consultation.status)"
          :consultation-id="id"
          @created="refetch"
        />
      </div>
    </div>
  </DashboardLayout>
</template>
