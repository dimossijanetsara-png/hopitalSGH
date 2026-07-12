<script setup>
import { ref, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import InfrastructureManager from '@/components/hospitalisation/InfrastructureManager.vue'
import { useAdmissionList, useAdmissionFilters } from '@/controllers/useHospitalisation'
import { HOSP_STATUSES, HOSP_STATUS_COLORS } from '@/models/hospitalisation.model'

const activeTab = ref('admissions')
const TABS = [
  { key: 'admissions', label: 'Admissions actives' },
  { key: 'infrastructure', label: 'Infrastructure' },
]

const { status, patientId, page, filters } = useAdmissionFilters()
const { data, loading } = useAdmissionList(filters)

const admissions = computed(() => data.value?.results || data.value || [])
const totalPages = computed(() => Math.ceil((data.value?.count || 0) / 20))
const totalItems = computed(() => data.value?.count || 0)

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', {
    day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit',
  })
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Hospitalisation</h1>
        <p class="text-sm text-gray-500 mt-0.5">Gestion des admissions et de l'infrastructure</p>
      </div>
      <RouterLink to="/hospitalisation/admissions/nouvelle">
        <AppButton>
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle admission
        </AppButton>
      </RouterLink>
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
        </button>
      </div>
    </div>

    <!-- Admissions tab -->
    <div v-if="activeTab === 'admissions'">
      <div class="flex flex-wrap gap-3 mb-4">
        <select
          v-model="status"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        >
          <option value="">Tous les statuts</option>
          <option v-for="s in HOSP_STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
        </select>
        <input
          v-model="patientId"
          type="text"
          placeholder="ID patient…"
          class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-48"
        />
      </div>

      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div v-if="loading" class="flex justify-center py-16">
          <AppSpinner size="lg" />
        </div>
        <div v-else-if="!admissions.length" class="text-center py-16 text-gray-400">
          <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 7h18M3 12h18M3 17h18" />
          </svg>
          <p>Aucune admission trouvée</p>
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Patient</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Lit / Service</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Admission</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
              <th class="text-right px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="a in admissions" :key="a.id" class="hover:bg-gray-50 transition-colors">
              <td class="px-4 py-3">
                <p class="font-medium text-gray-900">
                  {{ a.patient_full_name || a.patient?.full_name || 'Patient inconnu' }}
                </p>
                <p class="text-xs text-gray-400">{{ a.patient?.patient_id || a.patient }}</p>
              </td>
              <td class="px-4 py-3">
                <p class="text-gray-700">{{ a.bed?.number || a.bed || '–' }}</p>
                <p class="text-xs text-gray-400">{{ a.department?.name || '–' }}</p>
              </td>
              <td class="px-4 py-3 text-gray-600">{{ formatDate(a.admission_date) }}</td>
              <td class="px-4 py-3">
                <AppBadge :color-class="HOSP_STATUS_COLORS[a.status] || 'bg-gray-100 text-gray-600'">
                  {{ HOSP_STATUSES.find((s) => s.value === a.status)?.label || a.status }}
                </AppBadge>
              </td>
              <td class="px-4 py-3 text-right">
                <RouterLink
                  :to="{ name: 'admission-detail', params: { id: a.id } }"
                  class="text-blue-600 hover:underline text-xs font-medium"
                >
                  Voir
                </RouterLink>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="totalPages > 1" class="px-4 py-3 border-t border-gray-100">
          <AppPagination
            :current-page="page"
            :total-pages="totalPages"
            :total-items="totalItems"
            @change="page = $event"
          />
        </div>
      </div>
    </div>

    <!-- Infrastructure tab -->
    <div v-else-if="activeTab === 'infrastructure'">
      <InfrastructureManager />
    </div>
  </DashboardLayout>
</template>
