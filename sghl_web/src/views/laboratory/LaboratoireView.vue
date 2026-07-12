<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { exportToExcel, LAB_ORDER_COLUMNS } from '@/utils/export'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import LabTestSelector from '@/components/laboratory/LabTestSelector.vue'
import { useLabOrderList, useLabOrderFilters, useCreateLabOrder } from '@/controllers/useLaboratory'
import { LAB_ORDER_STATUSES, LAB_ORDER_STATUS_COLORS, LAB_PRIORITIES, LAB_PRIORITY_COLORS } from '@/models/laboratory.model'

const route = useRoute()
const { status, patientId, page, filters } = useLabOrderFilters()
const { data, loading } = useLabOrderList(filters)

const orders = computed(() => data.value?.results || data.value || [])
const totalPages = computed(() => Math.ceil((data.value?.count || 0) / 20))
const totalItems = computed(() => data.value?.count || 0)

// Create order — open modal automatically when navigated with ?create=1
const showCreate = ref(false)
watch(() => route.query.create, (val) => { if (val === '1') showCreate.value = true }, { immediate: true })
const createForm = ref({
  patient_id: '',
  test_ids: [],
  priority: 'NORMAL',
  clinical_notes: '',
  hospitalization_id: '',
  consultation_id: '',
})
const { submit: createOrder, loading: creating, error: createError } = useCreateLabOrder()

function resetForm() {
  createForm.value = { patient_id: '', test_ids: [], priority: 'NORMAL', clinical_notes: '', hospitalization_id: '', consultation_id: '' }
}

function handleCreate() {
  const payload = {
    patient_id: createForm.value.patient_id,
    test_ids: createForm.value.test_ids,
    priority: createForm.value.priority,
    clinical_notes: createForm.value.clinical_notes,
  }
  if (createForm.value.hospitalization_id) payload.hospitalization_id = createForm.value.hospitalization_id
  if (createForm.value.consultation_id) payload.consultation_id = createForm.value.consultation_id
  createOrder(payload, { onSuccess: () => { showCreate.value = false; resetForm() } })
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function statusLabel(v) {
  return LAB_ORDER_STATUSES.find((s) => s.value === v)?.label || v
}
function priorityLabel(v) {
  return LAB_PRIORITIES.find((p) => p.value === v)?.label || v
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Laboratoire</h1>
        <p class="text-sm text-gray-500 mt-0.5">Commandes d'analyses biologiques</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="exportToExcel(orders, LAB_ORDER_COLUMNS, 'laboratoire')">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Excel
        </AppButton>
        <AppButton @click="showCreate = true">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle commande
        </AppButton>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 mb-4">
      <select
        v-model="status"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      >
        <option value="">Tous les statuts</option>
        <option v-for="s in LAB_ORDER_STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
      </select>
      <input
        v-model="patientId"
        type="text"
        placeholder="ID patient…"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-48"
      />
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div v-if="loading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
      <div v-else-if="!orders.length" class="text-center py-16 text-gray-400">
        <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2" />
        </svg>
        <p>Aucune commande trouvée</p>
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Patient</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Analyses</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Priorité</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            <th class="text-right px-4 py-3"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="o in orders" :key="o.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-4 py-3">
              <p class="font-medium text-gray-900">{{ o.patient?.full_name || o.patient_id }}</p>
            </td>
            <td class="px-4 py-3">
              <span class="text-gray-700">{{ o.items?.length || 0 }} analyse(s)</span>
            </td>
            <td class="px-4 py-3">
              <AppBadge :color-class="LAB_PRIORITY_COLORS[o.priority] || 'bg-gray-100 text-gray-600'">
                {{ priorityLabel(o.priority) }}
              </AppBadge>
            </td>
            <td class="px-4 py-3">
              <AppBadge :color-class="LAB_ORDER_STATUS_COLORS[o.status] || 'bg-gray-100 text-gray-600'">
                {{ statusLabel(o.status) }}
              </AppBadge>
            </td>
            <td class="px-4 py-3 text-gray-500">{{ formatDate(o.created_at) }}</td>
            <td class="px-4 py-3 text-right">
              <RouterLink
                :to="{ name: 'lab-order-detail', params: { id: o.id } }"
                class="text-blue-600 hover:underline text-xs font-medium"
              >
                Voir
              </RouterLink>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="totalPages > 1" class="px-4 py-3 border-t border-gray-100">
        <AppPagination :current-page="page" :total-pages="totalPages" :total-items="totalItems" @change="page = $event" />
      </div>
    </div>

    <!-- Create modal -->
    <AppModal :open="showCreate" title="Nouvelle commande d'analyses" size="lg" @close="showCreate = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">
              ID Patient <span class="text-red-500">*</span>
            </label>
            <input
              v-model="createForm.patient_id"
              type="text"
              placeholder="UUID du patient"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Priorité</label>
            <select
              v-model="createForm.priority"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            >
              <option v-for="p in LAB_PRIORITIES" :key="p.value" :value="p.value">{{ p.label }}</option>
            </select>
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">ID Hospitalisation</label>
            <input
              v-model="createForm.hospitalization_id"
              type="text"
              placeholder="UUID (optionnel)"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">ID Consultation</label>
            <input
              v-model="createForm.consultation_id"
              type="text"
              placeholder="UUID (optionnel)"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Notes cliniques</label>
          <textarea
            v-model="createForm.clinical_notes"
            rows="2"
            placeholder="Contexte clinique, hypothèses diagnostiques…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
          />
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 block mb-2">
            Analyses <span class="text-red-500">*</span>
          </label>
          <LabTestSelector v-model="createForm.test_ids" />
        </div>
      </div>

      <template #footer>
        <AppButton variant="secondary" @click="showCreate = false">Annuler</AppButton>
        <AppButton
          :loading="creating"
          :disabled="!createForm.patient_id || !createForm.test_ids.length"
          @click="handleCreate"
        >
          Créer la commande
        </AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
