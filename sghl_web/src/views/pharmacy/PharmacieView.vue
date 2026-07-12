<script setup>
import { ref, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import BatchForm from '@/components/pharmacy/BatchForm.vue'
import DispensationForm from '@/components/pharmacy/DispensationForm.vue'
import {
  useMedications, useMedicationFilters, useLowStockAlerts,
  useStockMovements, useReceiveBatch, useCreateDispensation,
} from '@/controllers/usePharmacy'
import { MOVEMENT_TYPES, MOVEMENT_TYPE_COLORS, stockBadgeClass, stockLabel, stockStatusClass } from '@/models/pharmacy.model'

const activeTab = ref('medications')
const TABS = [
  { key: 'medications', label: 'Médicaments' },
  { key: 'alerts', label: 'Alertes stock' },
  { key: 'movements', label: 'Mouvements' },
]

// ─── Medications ──────────────────────────────────────────────────────────────
const { search, lowStock, params } = useMedicationFilters()
const { data: medsData, loading: medsLoading } = useMedications(params)
const medications = computed(() => medsData.value?.results || medsData.value || [])

// ─── Alerts ───────────────────────────────────────────────────────────────────
const { alerts, loading: alertsLoading } = useLowStockAlerts()

// ─── Movements ────────────────────────────────────────────────────────────────
const movMedId = ref(null)
const { movements, loading: movLoading } = useStockMovements(movMedId)
const movementsList = computed(() => movements.value?.results || movements.value || [])

// ─── Receive batch modal ──────────────────────────────────────────────────────
const showBatchModal = ref(false)
const batchMedId = ref('')
const { submit: receiveBatch, loading: receivingBatch, error: batchError } = useReceiveBatch()

function openBatchModal(medId = '') {
  batchMedId.value = medId
  showBatchModal.value = true
}

function handleBatch(data) {
  receiveBatch(data, { onSuccess: () => { showBatchModal.value = false } })
}

// ─── Dispensation modal ───────────────────────────────────────────────────────
const showDispModal = ref(false)
const { submit: createDisp, loading: dispensing, error: dispError } = useCreateDispensation()

function handleDisp(data) {
  createDisp(data, { onSuccess: () => { showDispModal.value = false } })
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function movTypeLabel(v) {
  return MOVEMENT_TYPES.find((t) => t.value === v)?.label || v
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Pharmacie</h1>
        <p class="text-sm text-gray-500 mt-0.5">Gestion des médicaments et dispensations</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="openBatchModal()">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Réception stock
        </AppButton>
        <AppButton @click="showDispModal = true">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Dispensation
        </AppButton>
      </div>
    </div>

    <!-- Alert banner -->
    <div v-if="alerts?.length" class="mb-4 bg-orange-50 border border-orange-200 rounded-xl px-4 py-3 flex items-center gap-2">
      <svg class="w-5 h-5 text-orange-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
      </svg>
      <p class="text-sm text-orange-700 font-medium">
        {{ alerts.length }} médicament(s) en rupture ou stock faible —
        <button class="underline" @click="activeTab = 'alerts'">voir les alertes</button>
      </p>
    </div>

    <!-- Tabs -->
    <div class="border-b border-gray-200 mb-6">
      <div class="flex gap-6">
        <button
          v-for="tab in TABS"
          :key="tab.key"
          :class="[
            'pb-3 text-sm font-medium transition-colors border-b-2 -mb-px',
            activeTab === tab.key
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700',
          ]"
          @click="activeTab = tab.key"
        >
          {{ tab.label }}
          <span v-if="tab.key === 'alerts' && alerts?.length"
            class="ml-1 bg-orange-500 text-white text-xs rounded-full px-1.5 py-0.5">
            {{ alerts.length }}
          </span>
        </button>
      </div>
    </div>

    <!-- ─── Medications tab ─── -->
    <div v-if="activeTab === 'medications'">
      <div class="flex flex-wrap gap-3 mb-4">
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher un médicament…"
          class="flex-1 min-w-[200px] px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
        <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
          <input v-model="lowStock" type="checkbox" class="rounded" />
          Stock faible uniquement
        </label>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div v-if="medsLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
        <div v-else-if="!medications.length" class="text-center py-16 text-gray-400">
          <p>Aucun médicament trouvé</p>
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Médicament</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Forme / Dosage</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Stock</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Prix unitaire</th>
              <th class="text-right px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="med in medications" :key="med.id" class="hover:bg-gray-50 transition-colors">
              <td class="px-4 py-3">
                <p class="font-medium text-gray-900">{{ med.name }}</p>
                <p class="text-xs text-gray-400">{{ med.generic_name }}</p>
              </td>
              <td class="px-4 py-3">
                <p class="text-gray-700">{{ med.dosage_form }}</p>
                <p class="text-xs text-gray-400">{{ med.strength }} · {{ med.unit }}</p>
              </td>
              <td class="px-4 py-3">
                <AppBadge :color-class="stockBadgeClass(med)">
                  {{ stockLabel(med) }}
                </AppBadge>
                <p :class="['text-xs mt-0.5', stockStatusClass(med)]">
                  {{ med.total_stock }} / seuil {{ med.reorder_threshold }}
                </p>
              </td>
              <td class="px-4 py-3 text-gray-700">
                {{ parseFloat(med.unit_price).toLocaleString('fr-FR') }} F
              </td>
              <td class="px-4 py-3 text-right">
                <button
                  class="text-blue-600 hover:underline text-xs font-medium mr-3"
                  @click="openBatchModal(med.id)"
                >
                  + Stock
                </button>
                <RouterLink
                  :to="{ name: 'medication-detail', params: { id: med.id } }"
                  class="text-blue-600 hover:underline text-xs font-medium"
                >
                  Détail
                </RouterLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ─── Alerts tab ─── -->
    <div v-else-if="activeTab === 'alerts'">
      <div v-if="alertsLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
      <div v-else-if="!alerts?.length" class="text-center py-16 text-gray-400">
        <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p>Aucune alerte de stock</p>
      </div>
      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="med in alerts"
          :key="med.id"
          :class="[
            'bg-white rounded-xl border p-4',
            med.total_stock === 0 ? 'border-red-300' : 'border-orange-200',
          ]"
        >
          <div class="flex items-start justify-between gap-2 mb-2">
            <div>
              <p class="font-semibold text-gray-900 text-sm">{{ med.name }}</p>
              <p class="text-xs text-gray-400">{{ med.category }}</p>
            </div>
            <AppBadge :color-class="stockBadgeClass(med)">{{ stockLabel(med) }}</AppBadge>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-gray-500">Stock actuel</span>
            <span :class="stockStatusClass(med)">{{ med.total_stock }} {{ med.unit }}</span>
          </div>
          <div class="flex items-center justify-between text-sm">
            <span class="text-gray-500">Seuil de commande</span>
            <span class="text-gray-700">{{ med.reorder_threshold }} {{ med.unit }}</span>
          </div>
          <AppButton size="sm" class="mt-3 w-full" @click="openBatchModal(med.id)">
            Commander un lot
          </AppButton>
        </div>
      </div>
    </div>

    <!-- ─── Movements tab ─── -->
    <div v-else-if="activeTab === 'movements'">
      <div class="flex gap-3 mb-4">
        <input
          v-model="movMedId"
          type="text"
          placeholder="Filtrer par ID médicament…"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-64"
        />
      </div>

      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div v-if="movLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
        <div v-else-if="!movementsList.length" class="text-center py-16 text-gray-400">Aucun mouvement</div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Type</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Lot</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Quantité</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Référence</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="m in movementsList" :key="m.id">
              <td class="px-4 py-3">
                <AppBadge :color-class="MOVEMENT_TYPE_COLORS[m.movement_type] || 'bg-gray-100 text-gray-600'">
                  {{ movTypeLabel(m.movement_type) }}
                </AppBadge>
              </td>
              <td class="px-4 py-3 text-gray-600 text-xs">{{ m.batch_id?.slice(0, 8) }}…</td>
              <td class="px-4 py-3 text-right font-semibold"
                :class="m.quantity > 0 ? 'text-green-600' : 'text-red-600'">
                {{ m.quantity > 0 ? '+' : '' }}{{ m.quantity }}
              </td>
              <td class="px-4 py-3 text-gray-500 text-xs">{{ m.reference || '–' }}</td>
              <td class="px-4 py-3 text-gray-400 text-xs">{{ formatDate(m.timestamp) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ─── Modals ─── -->
    <AppModal :open="showBatchModal" title="Réception de stock" size="md" @close="showBatchModal = false">
      <BatchForm
        :medication-id="batchMedId"
        :loading="receivingBatch"
        :error="batchError"
        @submit="handleBatch"
        @cancel="showBatchModal = false"
      />
    </AppModal>

    <AppModal :open="showDispModal" title="Dispensation" size="md" @close="showDispModal = false">
      <DispensationForm
        :loading="dispensing"
        :error="dispError"
        @submit="handleDisp"
        @cancel="showDispModal = false"
      />
    </AppModal>
  </DashboardLayout>
</template>
