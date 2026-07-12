<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { exportToExcel, APPOINTMENT_COLUMNS } from '@/utils/export'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'
import {
  useAppointmentList, useAppointmentFilters,
  useCreateAppointment, useUpdateAppointment,
} from '@/controllers/useAppointments'
import {
  APPOINTMENT_STATUSES, APPOINTMENT_STATUS_COLORS, NEXT_STATUSES,
} from '@/models/appointments.model'

const route = useRoute()
const { status, doctorId, patientId, page, filters } = useAppointmentFilters()
const { data, loading } = useAppointmentList(filters)
const appointments = computed(() => data.value?.results || data.value || [])
const totalPages = computed(() => Math.ceil((data.value?.count || 0) / 20))
const totalItems = computed(() => data.value?.count || 0)

// Create — open modal automatically when navigated with ?create=1
const showCreate = ref(false)
watch(() => route.query.create, (val) => { if (val === '1') showCreate.value = true }, { immediate: true })
const createForm = ref({
  patient_id: '', doctor_id: '', appointment_date: '',
  duration_minutes: 30, reason: '', notes: '',
})
const { submit: createAppt, loading: creating, error: createError } = useCreateAppointment()

function handleCreate() {
  createAppt({ ...createForm.value, duration_minutes: parseInt(createForm.value.duration_minutes) }, {
    onSuccess: () => {
      showCreate.value = false
      createForm.value = { patient_id: '', doctor_id: '', appointment_date: '', duration_minutes: 30, reason: '', notes: '' }
    },
  })
}

// Update status
const { submit: updateAppt, loading: updating } = useUpdateAppointment()
const showUpdateModal = ref(false)
const selectedAppt = ref(null)
const newStatus = ref('')
const cancelReason = ref('')
const updateNotes = ref('')

function openUpdate(appt) {
  selectedAppt.value = appt
  newStatus.value = ''
  cancelReason.value = ''
  updateNotes.value = appt.notes || ''
  showUpdateModal.value = true
}

function handleUpdate() {
  const payload = { notes: updateNotes.value }
  if (newStatus.value) payload.status = newStatus.value
  if (newStatus.value === 'CANCELLED' && cancelReason.value) payload.cancellation_reason = cancelReason.value
  updateAppt({ id: selectedAppt.value.id, data: payload }, {
    onSuccess: () => { showUpdateModal.value = false },
  })
}

function statusLabel(v) {
  return APPOINTMENT_STATUSES.find((s) => s.value === v)?.label || v
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', {
    weekday: 'short', day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  })
}
</script>

<template>
  <DashboardLayout>
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Rendez-vous</h1>
        <p class="text-sm text-gray-500 mt-0.5">Planning des consultations</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="exportToExcel(appointments, APPOINTMENT_COLUMNS, 'rendez-vous')">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Excel
        </AppButton>
        <AppButton @click="showCreate = true">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau rendez-vous
        </AppButton>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 mb-4">
      <select v-model="status"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300">
        <option value="">Tous les statuts</option>
        <option v-for="s in APPOINTMENT_STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
      </select>
      <input v-model="doctorId" type="text" placeholder="ID médecin…"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-44" />
      <input v-model="patientId" type="text" placeholder="ID patient…"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-44" />
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div v-if="loading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
      <div v-else-if="!appointments.length" class="text-center py-16 text-gray-400">
        <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <p>Aucun rendez-vous</p>
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Patient</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Médecin</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Motif</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Durée</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
            <th class="text-right px-4 py-3"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="appt in appointments" :key="appt.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-4 py-3 text-gray-700 text-xs whitespace-nowrap">
              {{ formatDate(appt.appointment_date) }}
            </td>
            <td class="px-4 py-3 text-xs text-gray-500">{{ appt.patient?.full_name || appt.patient_id }}</td>
            <td class="px-4 py-3 text-xs text-gray-500">{{ appt.doctor?.full_name || appt.doctor_id }}</td>
            <td class="px-4 py-3 text-sm text-gray-700 max-w-[180px] truncate">{{ appt.reason }}</td>
            <td class="px-4 py-3 text-center text-gray-500 text-xs">{{ appt.duration_minutes }}min</td>
            <td class="px-4 py-3">
              <AppBadge :color-class="APPOINTMENT_STATUS_COLORS[appt.status] || 'bg-gray-100 text-gray-600'">
                {{ statusLabel(appt.status) }}
              </AppBadge>
            </td>
            <td class="px-4 py-3 text-right">
              <button v-if="NEXT_STATUSES[appt.status]?.length"
                class="text-blue-600 hover:underline text-xs font-medium"
                @click="openUpdate(appt)">
                Modifier
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="totalPages > 1" class="px-4 py-3 border-t border-gray-100">
        <AppPagination :current-page="page" :total-pages="totalPages" :total-items="totalItems" @change="page = $event" />
      </div>
    </div>

    <!-- Create modal -->
    <AppModal :open="showCreate" title="Nouveau rendez-vous" size="md" @close="showCreate = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />
        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="createForm.patient_id" label="ID Patient" required placeholder="UUID" />
          <AppInput v-model="createForm.doctor_id" label="ID Médecin" required placeholder="UUID" />
        </div>
        <AppInput v-model="createForm.appointment_date" label="Date et heure" type="datetime-local" required />
        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="createForm.duration_minutes" label="Durée (min)" type="number" />
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">
              Motif <span class="text-red-500">*</span>
            </label>
            <input v-model="createForm.reason" type="text" placeholder="Raison de la consultation" required
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
          </div>
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
          <textarea v-model="createForm.notes" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showCreate = false">Annuler</AppButton>
        <AppButton :loading="creating" :disabled="!createForm.patient_id || !createForm.doctor_id || !createForm.reason"
          @click="handleCreate">Créer</AppButton>
      </template>
    </AppModal>

    <!-- Update modal -->
    <AppModal :open="showUpdateModal" title="Modifier le rendez-vous" size="sm" @close="showUpdateModal = false">
      <div class="space-y-4" v-if="selectedAppt">
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-2">Nouveau statut</label>
          <div class="flex flex-wrap gap-2">
            <button v-for="s in NEXT_STATUSES[selectedAppt.status]" :key="s"
              :class="[
                'px-3 py-1.5 rounded-lg text-sm border transition-colors',
                newStatus === s ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' : 'border-gray-200 hover:border-gray-300',
              ]"
              @click="newStatus = s">
              {{ statusLabel(s) }}
            </button>
          </div>
        </div>
        <div v-if="newStatus === 'CANCELLED'">
          <label class="text-sm font-medium text-gray-700 block mb-1">Motif d'annulation</label>
          <textarea v-model="cancelReason" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
          <textarea v-model="updateNotes" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showUpdateModal = false">Annuler</AppButton>
        <AppButton :loading="updating" @click="handleUpdate">Enregistrer</AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
