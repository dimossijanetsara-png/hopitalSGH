<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import PatientDocuments from '@/components/patients/PatientDocuments.vue'
import { usePatient, useArchivePatient } from '@/controllers/usePatients'
import { GENDER_LABELS, BLOOD_TYPE_COLORS, patientAge, formatDate } from '@/models/patient.model'
import { patientService } from '@/services/patient.service'

const route = useRoute()
const id = route.params.id

const { patient, loading } = usePatient(id)
const { archive, loading: archiving } = useArchivePatient()
const showArchiveModal = ref(false)
const tab = ref('info')

const tabs = [
  { key: 'info', label: 'Informations' },
  { key: 'documents', label: 'Documents' },
  { key: 'consent', label: 'Consentement' },
]

async function toggleConsent() {
  if (!patient.value) return
  await patientService.updateConsent(id, { consent_given: !patient.value.consent_given })
}
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20">
      <AppSpinner size="lg" />
    </div>

    <div v-else-if="patient">
      <!-- Header -->
      <div class="flex items-start justify-between mb-6">
        <div class="flex items-center gap-4">
          <RouterLink to="/patients" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div class="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-lg">
            {{ patient.first_name?.charAt(0) }}{{ patient.last_name?.charAt(0) }}
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h1 class="text-2xl font-bold text-gray-900">
                {{ patient.first_name }} {{ patient.last_name }}
              </h1>
              <AppBadge
                v-if="patient.is_archived"
                label="Archivé"
                color="bg-gray-100 text-gray-500"
              />
            </div>
            <p class="text-sm text-gray-500 font-mono mt-0.5">{{ patient.record_number }}</p>
          </div>
        </div>
        <div class="flex gap-2">
          <RouterLink :to="`/patients/${id}/modifier`">
            <AppButton variant="secondary" size="sm">Modifier</AppButton>
          </RouterLink>
          <AppButton
            v-if="!patient.is_archived"
            variant="danger"
            size="sm"
            @click="showArchiveModal = true"
          >
            Archiver
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
        </button>
      </div>

      <!-- Tab: Informations -->
      <div v-if="tab === 'info'" class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <!-- Infos principales -->
        <div class="lg:col-span-2 space-y-4">
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-4">Identité</h3>
            <dl class="grid grid-cols-2 gap-x-6 gap-y-3 text-sm">
              <div>
                <dt class="text-gray-400 text-xs">Prénom</dt>
                <dd class="text-gray-900 font-medium">{{ patient.first_name }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Nom</dt>
                <dd class="text-gray-900 font-medium">{{ patient.last_name }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Date de naissance</dt>
                <dd class="text-gray-900">{{ formatDate(patient.date_of_birth) }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Âge / Sexe</dt>
                <dd class="text-gray-900">{{ patientAge(patient.date_of_birth) }} · {{ GENDER_LABELS[patient.gender] }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">N° CNI / Passeport</dt>
                <dd class="text-gray-900">{{ patient.national_id || '—' }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Groupe sanguin</dt>
                <dd>
                  <AppBadge :label="patient.blood_type" :color="BLOOD_TYPE_COLORS[patient.blood_type]" />
                </dd>
              </div>
            </dl>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-4">Contact</h3>
            <dl class="grid grid-cols-2 gap-x-6 gap-y-3 text-sm">
              <div>
                <dt class="text-gray-400 text-xs">Téléphone</dt>
                <dd class="text-gray-900">{{ patient.phone || '—' }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">E-mail</dt>
                <dd class="text-gray-900">{{ patient.email || '—' }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Adresse</dt>
                <dd class="text-gray-900">{{ patient.address || '—' }}</dd>
              </div>
              <div>
                <dt class="text-gray-400 text-xs">Ville</dt>
                <dd class="text-gray-900">{{ patient.city || '—' }}</dd>
              </div>
            </dl>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-4">Informations médicales</h3>
            <div class="space-y-3 text-sm">
              <div>
                <p class="text-gray-400 text-xs mb-1">Allergies</p>
                <p class="text-gray-900 bg-red-50 rounded-lg p-2 text-xs">
                  {{ patient.allergies || 'Aucune allergie connue' }}
                </p>
              </div>
              <div>
                <p class="text-gray-400 text-xs mb-1">Pathologies chroniques</p>
                <p class="text-gray-900 bg-orange-50 rounded-lg p-2 text-xs">
                  {{ patient.chronic_conditions || 'Aucune pathologie chronique connue' }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-4">
          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-4">Contact d'urgence</h3>
            <div class="space-y-2 text-sm">
              <p class="text-gray-900 font-medium">{{ patient.emergency_contact_name || '—' }}</p>
              <p class="text-gray-600">{{ patient.emergency_contact_phone || '—' }}</p>
              <p class="text-gray-400 text-xs">{{ patient.emergency_contact_relation || '' }}</p>
            </div>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-4">Assurance</h3>
            <div class="space-y-2 text-sm">
              <p class="text-gray-900">{{ patient.insurance_provider || 'Non renseigné' }}</p>
              <p class="text-gray-400 text-xs font-mono">{{ patient.insurance_number || '' }}</p>
            </div>
          </div>

          <div class="bg-white rounded-xl border border-gray-200 p-5">
            <h3 class="text-sm font-semibold text-gray-700 mb-3">Actions rapides</h3>
            <div class="space-y-2">
              <RouterLink :to="`/consultations/nouvelle?patient=${id}`">
                <AppButton variant="secondary" size="sm" full>
                  Nouvelle consultation
                </AppButton>
              </RouterLink>
              <RouterLink :to="`/hospitalisation/admission?patient=${id}`">
                <AppButton variant="secondary" size="sm" full>
                  Admettre en hospitalisation
                </AppButton>
              </RouterLink>
              <RouterLink :to="`/rendez-vous/nouveau?patient=${id}`">
                <AppButton variant="secondary" size="sm" full>
                  Prendre un RDV
                </AppButton>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Documents -->
      <div v-if="tab === 'documents'" class="bg-white rounded-xl border border-gray-200 p-5">
        <PatientDocuments :patient-id="id" />
      </div>

      <!-- Tab: Consentement -->
      <div v-if="tab === 'consent'" class="bg-white rounded-xl border border-gray-200 p-5 max-w-lg">
        <h3 class="text-sm font-semibold text-gray-700 mb-4">Consentement médical</h3>
        <div :class="['flex items-center gap-4 p-4 rounded-lg border', patient.consent_given ? 'border-green-200 bg-green-50' : 'border-gray-200 bg-gray-50']">
          <svg :class="['w-8 h-8', patient.consent_given ? 'text-green-600' : 'text-gray-400']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          <div>
            <p class="font-medium text-gray-900">
              {{ patient.consent_given ? 'Consentement accordé' : 'Consentement non recueilli' }}
            </p>
            <p v-if="patient.consent_date" class="text-xs text-gray-500 mt-0.5">
              Le {{ formatDate(patient.consent_date) }}
            </p>
          </div>
        </div>
        <AppButton class="mt-4" :variant="patient.consent_given ? 'danger' : 'primary'" @click="toggleConsent">
          {{ patient.consent_given ? 'Révoquer le consentement' : 'Enregistrer le consentement' }}
        </AppButton>
      </div>
    </div>

    <!-- Archive modal -->
    <AppModal :open="showArchiveModal" title="Archiver le patient" @close="showArchiveModal = false">
      <p class="text-sm text-gray-600">
        Êtes-vous sûr de vouloir archiver
        <strong>{{ patient?.first_name }} {{ patient?.last_name }}</strong> ?
        Le dossier sera conservé mais n'apparaîtra plus dans la liste principale.
      </p>
      <template #footer>
        <AppButton variant="secondary" @click="showArchiveModal = false">Annuler</AppButton>
        <AppButton variant="danger" :loading="archiving" @click="archive(id)">Archiver</AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
