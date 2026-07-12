<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { exportToExcel, INVOICE_COLUMNS } from '@/utils/export'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import InvoiceItemsEditor from '@/components/billing/InvoiceItemsEditor.vue'
import {
  useInvoiceList, useInvoiceFilters, useCreateInvoice,
} from '@/controllers/useBilling'
import {
  INVOICE_STATUSES, INVOICE_STATUS_COLORS, formatMoney,
} from '@/models/billing.model'

const route = useRoute()
const { status, patientId, page, filters } = useInvoiceFilters()
const { data, loading } = useInvoiceList(filters)
const invoices = computed(() => data.value?.results || data.value || [])
const totalPages = computed(() => Math.ceil((data.value?.count || 0) / 20))
const totalItems = computed(() => data.value?.count || 0)

// Create invoice — open modal automatically when navigated with ?create=1
const showCreate = ref(false)
watch(() => route.query.create, (val) => { if (val === '1') showCreate.value = true }, { immediate: true })
const form = ref({
  patient_id: '',
  hospitalization_id: '',
  discount: 0,
  tax: 0,
  insurance_provider: '',
  insurance_coverage: 0,
  insurance_claim_number: '',
  notes: '',
  items: [],
})
const { submit: createInvoice, loading: creating, error: createError } = useCreateInvoice()

function resetForm() {
  form.value = {
    patient_id: '', hospitalization_id: '',
    discount: 0, tax: 0,
    insurance_provider: '', insurance_coverage: 0, insurance_claim_number: '',
    notes: '', items: [],
  }
}

function handleCreate() {
  const payload = {
    patient_id: form.value.patient_id,
    items: form.value.items.map((it) => ({
      item_type: it.item_type,
      description: it.description,
      quantity: parseInt(it.quantity) || 1,
      unit_price: parseFloat(it.unit_price) || 0,
      discount_percent: parseFloat(it.discount_percent) || 0,
      reference_id: it.reference_id || '',
    })),
    discount: parseFloat(form.value.discount) || 0,
    tax: parseFloat(form.value.tax) || 0,
    notes: form.value.notes,
  }
  if (form.value.hospitalization_id) payload.hospitalization_id = form.value.hospitalization_id
  if (form.value.insurance_provider) {
    payload.insurance_provider = form.value.insurance_provider
    payload.insurance_coverage = parseFloat(form.value.insurance_coverage) || 0
    payload.insurance_claim_number = form.value.insurance_claim_number
  }
  createInvoice(payload, { onSuccess: () => { showCreate.value = false; resetForm() } })
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function statusLabel(v) {
  return INVOICE_STATUSES.find((s) => s.value === v)?.label || v
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Facturation</h1>
        <p class="text-sm text-gray-500 mt-0.5">Gestion des factures et paiements</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="exportToExcel(invoices, INVOICE_COLUMNS, 'facturation')">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Excel
        </AppButton>
        <AppButton @click="showCreate = true">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle facture
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
        <option v-for="s in INVOICE_STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
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
      <div v-else-if="!invoices.length" class="text-center py-16 text-gray-400">
        <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 14H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v2M9 14l6 6m0 0l6-6m-6 6V10" />
        </svg>
        <p>Aucune facture trouvée</p>
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">N° Facture</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Patient</th>
            <th class="text-right px-4 py-3 font-medium text-gray-600">Total</th>
            <th class="text-right px-4 py-3 font-medium text-gray-600">Solde restant</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            <th class="text-right px-4 py-3"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="inv in invoices" :key="inv.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-4 py-3 font-mono text-xs text-gray-700">{{ inv.invoice_number || '–' }}</td>
            <td class="px-4 py-3">
              <p class="font-medium text-gray-900">{{ inv.patient?.full_name || inv.patient_id }}</p>
            </td>
            <td class="px-4 py-3 text-right font-semibold text-gray-800">
              {{ formatMoney(inv.total) }}
            </td>
            <td class="px-4 py-3 text-right"
              :class="parseFloat(inv.balance_due) > 0 ? 'text-orange-600 font-semibold' : 'text-green-600'">
              {{ formatMoney(inv.balance_due) }}
            </td>
            <td class="px-4 py-3">
              <AppBadge :color-class="INVOICE_STATUS_COLORS[inv.status] || 'bg-gray-100 text-gray-600'">
                {{ statusLabel(inv.status) }}
              </AppBadge>
            </td>
            <td class="px-4 py-3 text-gray-400 text-xs">{{ formatDate(inv.created_at) }}</td>
            <td class="px-4 py-3 text-right">
              <RouterLink
                :to="{ name: 'invoice-detail', params: { id: inv.id } }"
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
    <AppModal :open="showCreate" title="Nouvelle facture" size="xl" @close="showCreate = false">
      <div class="space-y-5">
        <AppAlert v-if="createError" type="error" :message="createError" />

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">
              ID Patient <span class="text-red-500">*</span>
            </label>
            <input
              v-model="form.patient_id"
              type="text"
              placeholder="UUID du patient"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">ID Hospitalisation</label>
            <input
              v-model="form.hospitalization_id"
              type="text"
              placeholder="UUID (optionnel)"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>
        </div>

        <!-- Items -->
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-2">
            Articles <span class="text-red-500">*</span>
          </label>
          <InvoiceItemsEditor v-model="form.items" />
        </div>

        <!-- Totals -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div>
            <label class="text-xs text-gray-500 block mb-1">Remise globale (F)</label>
            <input v-model="form.discount" type="number" step="0.01" min="0" placeholder="0"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
          </div>
          <div>
            <label class="text-xs text-gray-500 block mb-1">Taxes (F)</label>
            <input v-model="form.tax" type="number" step="0.01" min="0" placeholder="0"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
          </div>
          <div>
            <label class="text-xs text-gray-500 block mb-1">Assureur</label>
            <input v-model="form.insurance_provider" type="text" placeholder="Nom assurance"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
          </div>
          <div>
            <label class="text-xs text-gray-500 block mb-1">Prise en charge (F)</label>
            <input v-model="form.insurance_coverage" type="number" step="0.01" min="0" placeholder="0"
              class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
          </div>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Notes</label>
          <textarea v-model="form.notes" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>

      <template #footer>
        <AppButton variant="secondary" @click="showCreate = false">Annuler</AppButton>
        <AppButton
          :loading="creating"
          :disabled="!form.patient_id || !form.items.length"
          @click="handleCreate"
        >
          Créer la facture
        </AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
