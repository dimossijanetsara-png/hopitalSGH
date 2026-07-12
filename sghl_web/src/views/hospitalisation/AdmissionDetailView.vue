<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import DischargeModal from '@/components/hospitalisation/DischargeModal.vue'
import TransferModal from '@/components/hospitalisation/TransferModal.vue'
import { useAdmission, useDischarge, useTransfer } from '@/controllers/useHospitalisation'
import { useAuthStore } from '@/stores/auth.store'
import { HOSP_STATUSES, HOSP_STATUS_COLORS } from '@/models/hospitalisation.model'

const route = useRoute()
const auth = useAuthStore()

const admissionId = route.params.id
const { admission, loading } = useAdmission(admissionId)

const { submit: discharge, loading: discharging, error: dischargeError } = useDischarge(admissionId)
const { submit: transfer, loading: transferring, error: transferError } = useTransfer(admissionId)

const showDischarge = ref(false)
const showTransfer = ref(false)

const isActive = computed(() => admission.value?.status === 'ACTIVE')
const canManage = computed(() => ['ADMIN', 'DOCTOR', 'NURSE'].includes(auth.user?.role))

function onDischarge(data) {
  discharge(data, {
    onSuccess: () => { showDischarge.value = false },
  })
}

function onTransfer(data) {
  transfer(data, {
    onSuccess: () => { showTransfer.value = false },
  })
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', {
    day: '2-digit', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit',
  })
}

function duration(from, to) {
  const start = new Date(from)
  const end = to ? new Date(to) : new Date()
  const days = Math.floor((end - start) / 86400000)
  return days === 0 ? 'Moins d\'un jour' : `${days} jour${days > 1 ? 's' : ''}`
}
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20">
      <AppSpinner size="xl" />
    </div>

    <div v-else-if="admission">
      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4 mb-6">
        <div class="flex items-center gap-3">
          <RouterLink to="/hospitalisation" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div>
            <h1 class="text-2xl font-bold text-gray-900">
              {{ admission.patient_full_name || admission.patient?.full_name || 'Patient inconnu' }}
            </h1>
            <p class="text-sm text-gray-500 mt-0.5">Admission · {{ admission.id?.slice(0, 8) }}</p>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <AppBadge :color-class="HOSP_STATUS_COLORS[admission.status] || 'bg-gray-100 text-gray-600'">
            {{ HOSP_STATUSES.find((s) => s.value === admission.status)?.label || admission.status }}
          </AppBadge>

          <template v-if="isActive && canManage">
            <AppButton size="sm" variant="secondary" @click="showTransfer = true">
              Transférer
            </AppButton>
            <AppButton size="sm" variant="danger" @click="showDischarge = true">
              Enregistrer sortie
            </AppButton>
          </template>
        </div>
      </div>

      <!-- Info cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
        <!-- Admission info -->
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Séjour</h3>
          <dl class="space-y-2">
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Entrée</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(admission.admission_date) }}</dd>
            </div>
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Sortie</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(admission.discharge_date) }}</dd>
            </div>
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Durée</dt>
              <dd class="text-gray-900 font-medium">{{ duration(admission.admission_date, admission.discharge_date) }}</dd>
            </div>
          </dl>
        </div>

        <!-- Bed info -->
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Localisation</h3>
          <dl class="space-y-2">
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Lit</dt>
              <dd class="text-gray-900 font-medium">{{ admission.bed?.number || admission.bed || '–' }}</dd>
            </div>
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Chambre</dt>
              <dd class="text-gray-900 font-medium">{{ admission.room?.number || '–' }}</dd>
            </div>
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Service</dt>
              <dd class="text-gray-900 font-medium">{{ admission.department?.name || '–' }}</dd>
            </div>
          </dl>
        </div>

        <!-- Medical info -->
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Médical</h3>
          <dl class="space-y-2">
            <div class="flex justify-between text-sm">
              <dt class="text-gray-500">Médecin</dt>
              <dd class="text-gray-900 font-medium">
                {{ admission.treating_doctor?.full_name || admission.treating_doctor || '–' }}
              </dd>
            </div>
          </dl>
        </div>
      </div>

      <!-- Reason & notes -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Motif d'hospitalisation</h3>
          <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ admission.reason || '–' }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Notes</h3>
          <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ admission.notes || '–' }}</p>
        </div>
      </div>

      <!-- Discharge notes (if discharged) -->
      <div v-if="admission.discharge_notes" class="mt-4 bg-white rounded-xl border border-gray-200 p-4">
        <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Notes de sortie</h3>
        <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ admission.discharge_notes }}</p>
      </div>
    </div>

    <!-- Modals -->
    <DischargeModal
      :open="showDischarge"
      :loading="discharging"
      :error="dischargeError"
      @close="showDischarge = false"
      @submit="onDischarge"
    />

    <TransferModal
      :open="showTransfer"
      :loading="transferring"
      :error="transferError"
      @close="showTransfer = false"
      @submit="onTransfer"
    />
  </DashboardLayout>
</template>
