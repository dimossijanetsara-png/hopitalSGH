<script setup>
import { ref, computed } from 'vue'
import { exportToExcel, STAFF_COLUMNS } from '@/utils/export'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'
import {
  useStaffList, useCreateStaff,
  useShiftList, useShiftFilters, useCreateShift, useConfirmShift,
} from '@/controllers/useHR'
import { SHIFT_TYPES, SHIFT_TYPE_COLORS, SHIFT_TYPE_BG } from '@/models/hr.model'

const activeTab = ref('staff')

// ─── Staff ─────────────────────────────────────────────────────────────────
const deptFilter = ref(null)
const { data: staffData, loading: staffLoading } = useStaffList(deptFilter)
const staff = computed(() => staffData.value?.results || staffData.value || [])

const showStaffModal = ref(false)
const staffForm = ref({ user_id: '', employee_number: '', specialization: '', license_number: '', hire_date: '', department_id: '' })
const { submit: createStaff, loading: creatingStaff, error: staffError } = useCreateStaff()

function handleCreateStaff() {
  const payload = { ...staffForm.value }
  if (!payload.department_id) delete payload.department_id
  if (!payload.hire_date) delete payload.hire_date
  createStaff(payload, { onSuccess: () => { showStaffModal.value = false } })
}

// ─── Shifts ────────────────────────────────────────────────────────────────
const { departmentId: shiftDept, staffId: shiftStaff, filters: shiftFilters } = useShiftFilters()
const { data: shiftsData, loading: shiftsLoading } = useShiftList(shiftFilters)
const shifts = computed(() => shiftsData.value?.results || shiftsData.value || [])

const showShiftModal = ref(false)
const shiftForm = ref({ staff_id: '', department_id: '', shift_type: 'MORNING', start_datetime: '', end_datetime: '', notes: '' })
const { submit: createShift, loading: creatingShift, error: shiftError } = useCreateShift()
const { confirm: confirmShift, loading: confirming } = useConfirmShift()

function handleCreateShift() {
  createShift({ ...shiftForm.value }, { onSuccess: () => { showShiftModal.value = false } })
}

function shiftTypeLabel(v) {
  return SHIFT_TYPES.find((t) => t.value === v)?.label || v
}

function formatDatetime(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })
}

function shiftDuration(start, end) {
  if (!start || !end) return ''
  const h = Math.round((new Date(end) - new Date(start)) / 3600000)
  return `${h}h`
}
</script>

<template>
  <DashboardLayout>
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Ressources Humaines</h1>
        <p class="text-sm text-gray-500 mt-0.5">Personnel et planning des gardes</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="exportToExcel(staff, STAFF_COLUMNS, 'personnel')">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Excel
        </AppButton>
        <AppButton v-if="activeTab === 'staff'" @click="showStaffModal = true">+ Ajouter personnel</AppButton>
        <AppButton v-else @click="showShiftModal = true">+ Planifier une garde</AppButton>
      </div>
    </div>

    <!-- Tabs -->
    <div class="border-b border-gray-200 mb-6">
      <div class="flex gap-6">
        <button v-for="tab in [{ key: 'staff', label: 'Personnel' }, { key: 'shifts', label: 'Planning gardes' }]"
          :key="tab.key"
          :class="['pb-3 text-sm font-medium transition-colors border-b-2 -mb-px',
            activeTab === tab.key ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700']"
          @click="activeTab = tab.key">
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- ─── Staff tab ─── -->
    <div v-if="activeTab === 'staff'">
      <div class="flex gap-3 mb-4">
        <input v-model="deptFilter" type="text" placeholder="Filtrer par ID service…"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-56" />
      </div>
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div v-if="staffLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
        <div v-else-if="!staff.length" class="text-center py-16 text-gray-400">
          <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <p>Aucun membre du personnel</p>
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Matricule</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Spécialisation</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">N° licence</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Embauche</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="s in staff" :key="s.id" class="hover:bg-gray-50">
              <td class="px-4 py-3 font-mono text-xs text-gray-700">{{ s.employee_number }}</td>
              <td class="px-4 py-3 text-gray-700">{{ s.specialization || '–' }}</td>
              <td class="px-4 py-3 text-gray-500 text-xs">{{ s.license_number || '–' }}</td>
              <td class="px-4 py-3 text-gray-500 text-xs">{{ s.hire_date || '–' }}</td>
              <td class="px-4 py-3">
                <AppBadge :color-class="s.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'">
                  {{ s.is_active ? 'Actif' : 'Inactif' }}
                </AppBadge>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ─── Shifts tab ─── -->
    <div v-else-if="activeTab === 'shifts'">
      <div class="flex flex-wrap gap-3 mb-4">
        <input v-model="shiftDept" type="text" placeholder="ID service…"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-44" />
        <input v-model="shiftStaff" type="text" placeholder="ID personnel…"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-44" />
      </div>

      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div v-if="shiftsLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
        <div v-else-if="!shifts.length" class="text-center py-16 text-gray-400">
          <p>Aucune garde planifiée</p>
        </div>
        <div v-else class="divide-y divide-gray-100">
          <div v-for="shift in shifts" :key="shift.id"
            :class="['flex items-center justify-between gap-4 px-4 py-3 border-l-4', SHIFT_TYPE_BG[shift.shift_type] || '']">
            <div class="min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <AppBadge :color-class="SHIFT_TYPE_COLORS[shift.shift_type] || 'bg-gray-100 text-gray-600'">
                  {{ shiftTypeLabel(shift.shift_type) }}
                </AppBadge>
                <AppBadge :color-class="shift.is_confirmed ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'">
                  {{ shift.is_confirmed ? 'Confirmée' : 'Non confirmée' }}
                </AppBadge>
              </div>
              <p class="text-sm text-gray-700 mt-1">
                {{ formatDatetime(shift.start_datetime) }} → {{ formatDatetime(shift.end_datetime) }}
                <span class="text-xs text-gray-400 ml-1">({{ shiftDuration(shift.start_datetime, shift.end_datetime) }})</span>
              </p>
              <p v-if="shift.notes" class="text-xs text-gray-400 mt-0.5 truncate max-w-sm">{{ shift.notes }}</p>
            </div>
            <AppButton v-if="!shift.is_confirmed" size="sm" variant="success" :loading="confirming"
              @click="confirmShift(shift.id)">
              Confirmer
            </AppButton>
          </div>
        </div>
      </div>
    </div>

    <!-- Staff modal -->
    <AppModal :open="showStaffModal" title="Nouveau membre du personnel" size="md" @close="showStaffModal = false">
      <div class="space-y-4">
        <AppAlert v-if="staffError" type="error" :message="staffError" />
        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="staffForm.user_id" label="ID Utilisateur" required placeholder="UUID" />
          <AppInput v-model="staffForm.employee_number" label="Matricule" required placeholder="EMP-001" />
          <AppInput v-model="staffForm.specialization" label="Spécialisation" placeholder="Cardiologie…" />
          <AppInput v-model="staffForm.license_number" label="N° licence" placeholder="LIC-2024-XXX" />
          <AppInput v-model="staffForm.hire_date" label="Date d'embauche" type="date" />
          <AppInput v-model="staffForm.department_id" label="ID Service" placeholder="UUID (optionnel)" />
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showStaffModal = false">Annuler</AppButton>
        <AppButton :loading="creatingStaff" @click="handleCreateStaff">Enregistrer</AppButton>
      </template>
    </AppModal>

    <!-- Shift modal -->
    <AppModal :open="showShiftModal" title="Planifier une garde" size="md" @close="showShiftModal = false">
      <div class="space-y-4">
        <AppAlert v-if="shiftError" type="error" :message="shiftError" />
        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="shiftForm.staff_id" label="ID Personnel" required placeholder="UUID" />
          <AppInput v-model="shiftForm.department_id" label="ID Service" required placeholder="UUID" />
          <AppInput v-model="shiftForm.start_datetime" label="Début" type="datetime-local" required />
          <AppInput v-model="shiftForm.end_datetime" label="Fin" type="datetime-local" required />
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-2">Type de garde</label>
          <div class="grid grid-cols-2 gap-2">
            <label v-for="t in SHIFT_TYPES" :key="t.value"
              :class="['flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer text-sm transition-colors',
                shiftForm.shift_type === t.value ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium' : 'border-gray-200 hover:border-gray-300']">
              <input v-model="shiftForm.shift_type" type="radio" :value="t.value" class="hidden" />
              {{ t.label }}
            </label>
          </div>
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
          <textarea v-model="shiftForm.notes" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showShiftModal = false">Annuler</AppButton>
        <AppButton :loading="creatingShift" @click="handleCreateShift">Planifier</AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
