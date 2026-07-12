<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import BatchForm from '@/components/pharmacy/BatchForm.vue'
import { useMedication, useBatches, useReceiveBatch } from '@/controllers/usePharmacy'
import { stockBadgeClass, stockLabel, stockStatusClass } from '@/models/pharmacy.model'

const route = useRoute()
const medId = route.params.id

const { medication, loading } = useMedication(medId)
const { batches, loading: batchesLoading } = useBatches(ref(medId))

const showBatchModal = ref(false)
const { submit: receiveBatch, loading: receivingBatch, error: batchError } = useReceiveBatch()

function handleBatch(data) {
  receiveBatch(data, { onSuccess: () => { showBatchModal.value = false } })
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

const batchList = (batches) => batches?.results || batches || []
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20"><AppSpinner size="xl" /></div>

    <div v-else-if="medication">
      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4 mb-6">
        <div class="flex items-center gap-3">
          <RouterLink to="/pharmacie" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{{ medication.name }}</h1>
            <p class="text-sm text-gray-500">{{ medication.generic_name }}</p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <AppBadge :color-class="stockBadgeClass(medication)">{{ stockLabel(medication) }}</AppBadge>
          <AppButton size="sm" @click="showBatchModal = true">+ Réceptionner un lot</AppButton>
        </div>
      </div>

      <!-- Info -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <p class="text-xs text-gray-400 mb-1">Catégorie</p>
          <p class="font-semibold text-gray-800">{{ medication.category }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <p class="text-xs text-gray-400 mb-1">Forme / Dosage</p>
          <p class="font-semibold text-gray-800">{{ medication.dosage_form }} · {{ medication.strength }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <p class="text-xs text-gray-400 mb-1">Stock total</p>
          <p :class="['text-2xl font-bold', stockStatusClass(medication)]">
            {{ medication.total_stock }}
            <span class="text-sm font-normal text-gray-400">{{ medication.unit }}</span>
          </p>
          <p class="text-xs text-gray-400 mt-0.5">Seuil : {{ medication.reorder_threshold }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <p class="text-xs text-gray-400 mb-1">Prix unitaire</p>
          <p class="text-xl font-bold text-gray-800">
            {{ parseFloat(medication.unit_price).toLocaleString('fr-FR') }}
            <span class="text-sm font-normal text-gray-400">F</span>
          </p>
        </div>
      </div>

      <!-- Batches -->
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100">
          <h3 class="font-semibold text-gray-800">Lots en stock</h3>
        </div>
        <div v-if="batchesLoading" class="flex justify-center py-12"><AppSpinner /></div>
        <div v-else-if="!batchList(batches).length" class="text-center py-12 text-gray-400 text-sm">
          Aucun lot enregistré
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Numéro de lot</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Quantité</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Péremption</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Fournisseur</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Réception</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">État</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr
              v-for="batch in batchList(batches)"
              :key="batch.id"
              :class="batch.is_expired ? 'opacity-50' : ''"
            >
              <td class="px-4 py-3 font-mono text-xs text-gray-700">{{ batch.batch_number }}</td>
              <td class="px-4 py-3 text-right font-semibold" :class="batch.quantity === 0 ? 'text-red-600' : 'text-gray-900'">
                {{ batch.quantity }}
              </td>
              <td class="px-4 py-3" :class="batch.is_expired ? 'text-red-600' : 'text-gray-600'">
                {{ formatDate(batch.expiry_date) }}
              </td>
              <td class="px-4 py-3 text-gray-500">{{ batch.supplier || '–' }}</td>
              <td class="px-4 py-3 text-gray-400 text-xs">{{ formatDate(batch.received_at) }}</td>
              <td class="px-4 py-3">
                <AppBadge v-if="batch.is_expired" color-class="bg-red-100 text-red-600">Périmé</AppBadge>
                <AppBadge v-else-if="batch.quantity === 0" color-class="bg-gray-100 text-gray-500">Épuisé</AppBadge>
                <AppBadge v-else color-class="bg-green-100 text-green-700">Actif</AppBadge>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <AppModal :open="showBatchModal" title="Réception de stock" size="md" @close="showBatchModal = false">
      <BatchForm
        :medication-id="medId"
        :loading="receivingBatch"
        :error="batchError"
        @submit="handleBatch"
        @cancel="showBatchModal = false"
      />
    </AppModal>
  </DashboardLayout>
</template>
