<script setup>
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSearchBar from '@/components/ui/AppSearchBar.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { useConsultationList, useConsultationFilters } from '@/controllers/useClinical'
import {
  CONSULTATION_STATUSES,
  CONSULTATION_STATUS_COLORS,
} from '@/models/clinical.model'
import { formatDate } from '@/models/patient.model'

const { search, status, page, filters } = useConsultationFilters()
const { data, loading } = useConsultationList(filters)
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Consultations</h1>
        <p class="text-sm text-gray-500 mt-0.5">{{ data?.count ?? '—' }} consultation(s)</p>
      </div>
      <RouterLink to="/consultations/nouvelle">
        <AppButton>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouvelle consultation
        </AppButton>
      </RouterLink>
    </div>

    <!-- Filtres -->
    <div class="flex flex-wrap items-center gap-3 mb-4">
      <AppSearchBar
        v-model="search"
        placeholder="Rechercher par patient, médecin…"
        class="flex-1 min-w-48 max-w-md"
      />
      <select
        v-model="status"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      >
        <option value="">Tous les statuts</option>
        <option v-for="s in CONSULTATION_STATUSES" :key="s.value" :value="s.value">
          {{ s.label }}
        </option>
      </select>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div v-if="loading" class="p-4 space-y-3">
        <div v-for="i in 6" :key="i" class="h-14 bg-gray-100 rounded-lg animate-pulse" />
      </div>

      <div v-else-if="!data?.results?.length" class="flex flex-col items-center justify-center py-16 text-gray-400">
        <svg class="w-12 h-12 mb-3 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
        <p class="text-sm font-medium">Aucune consultation trouvée</p>
      </div>

      <table v-else class="w-full text-sm">
        <thead>
          <tr class="border-b border-gray-200 bg-gray-50 text-left">
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Patient</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Médecin</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Motif</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Date</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Statut</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Diagnostics</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr
            v-for="c in data.results"
            :key="c.id"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3">
              <p class="font-medium text-gray-900">
                {{ c.patient?.first_name }} {{ c.patient?.last_name }}
              </p>
              <p class="text-xs text-gray-400 font-mono">{{ c.patient?.record_number }}</p>
            </td>
            <td class="px-4 py-3 text-gray-600">
              Dr. {{ c.doctor?.first_name }} {{ c.doctor?.last_name }}
            </td>
            <td class="px-4 py-3 text-gray-600 max-w-48">
              <p class="truncate">{{ c.chief_complaint || '—' }}</p>
            </td>
            <td class="px-4 py-3 text-gray-500 text-xs whitespace-nowrap">
              {{ formatDate(c.consultation_date) }}
            </td>
            <td class="px-4 py-3">
              <AppBadge
                :label="CONSULTATION_STATUSES.find((s) => s.value === c.status)?.label ?? c.status"
                :color="CONSULTATION_STATUS_COLORS[c.status]"
              />
            </td>
            <td class="px-4 py-3 text-center text-xs text-gray-500">
              {{ c.diagnoses?.length ?? 0 }}
            </td>
            <td class="px-4 py-3">
              <RouterLink
                :to="`/consultations/${c.id}`"
                class="text-blue-600 hover:text-blue-800 text-xs font-medium"
              >
                Voir →
              </RouterLink>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="data?.count > 20" class="px-4 py-3 border-t border-gray-200">
        <AppPagination
          :current-page="page"
          :total-pages="Math.ceil(data.count / 20)"
          :total-items="data.count"
          :page-size="20"
          @change="page = $event"
        />
      </div>
    </div>
  </DashboardLayout>
</template>
