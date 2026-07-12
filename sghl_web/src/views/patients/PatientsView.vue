<script setup>
import { ref, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppSearchBar from '@/components/ui/AppSearchBar.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { usePatientList, usePatientSearch } from '@/controllers/usePatients'
import { GENDER_LABELS, BLOOD_TYPE_COLORS, patientAge, formatDate } from '@/models/patient.model'
import { exportToExcel, PATIENT_COLUMNS } from '@/utils/export'

const { search, showArchived, page, filters } = usePatientSearch()
const { data, loading } = usePatientList(filters)
const patients = computed(() => data.value?.results || data.value || [])

function handleExport() {
  exportToExcel(patients.value, PATIENT_COLUMNS, 'patients')
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Patients</h1>
        <p class="text-sm text-gray-500 mt-0.5">
          {{ data?.count ?? '—' }} patient(s) enregistré(s)
        </p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="handleExport">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Excel
        </AppButton>
        <RouterLink to="/patients/nouveau">
        <AppButton>
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau patient
        </AppButton>
      </RouterLink>
      </div>
    </div>

    <!-- Filtres -->
    <div class="flex items-center gap-3 mb-4">
      <AppSearchBar
        v-model="search"
        placeholder="Rechercher par nom, n° dossier, téléphone…"
        class="flex-1 max-w-md"
      />
      <label class="flex items-center gap-2 text-sm text-gray-600 cursor-pointer select-none">
        <input type="checkbox" v-model="showArchived" class="rounded" />
        Inclure archivés
      </label>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <!-- Loading skeleton -->
      <div v-if="loading" class="p-4 space-y-3">
        <div v-for="i in 8" :key="i" class="h-12 bg-gray-100 rounded-lg animate-pulse" />
      </div>

      <!-- Empty state -->
      <div
        v-else-if="!data?.results?.length"
        class="flex flex-col items-center justify-center py-16 text-gray-400"
      >
        <svg class="w-12 h-12 mb-3 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <p class="text-sm font-medium">Aucun patient trouvé</p>
        <p class="text-xs mt-1">Essayez d'autres critères ou créez un nouveau patient.</p>
      </div>

      <!-- Table content -->
      <table v-else class="w-full text-sm">
        <thead>
          <tr class="border-b border-gray-200 bg-gray-50 text-left">
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Patient</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">N° Dossier</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Âge / Sexe</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Groupe</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Téléphone</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Enregistré le</th>
            <th class="px-4 py-3 font-medium text-gray-500 text-xs uppercase tracking-wide">Statut</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr
            v-for="patient in data.results"
            :key="patient.id"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-semibold text-xs shrink-0">
                  {{ patient.first_name?.charAt(0) }}{{ patient.last_name?.charAt(0) }}
                </div>
                <div>
                  <p class="font-medium text-gray-900">{{ patient.first_name }} {{ patient.last_name }}</p>
                  <p v-if="patient.email" class="text-xs text-gray-400">{{ patient.email }}</p>
                </div>
              </div>
            </td>
            <td class="px-4 py-3 font-mono text-xs text-gray-600">{{ patient.record_number }}</td>
            <td class="px-4 py-3 text-gray-600">
              {{ patientAge(patient.date_of_birth) }} · {{ GENDER_LABELS[patient.gender] }}
            </td>
            <td class="px-4 py-3">
              <AppBadge
                v-if="patient.blood_type && patient.blood_type !== 'INC'"
                :label="patient.blood_type"
                :color="BLOOD_TYPE_COLORS[patient.blood_type]"
              />
              <span v-else class="text-gray-400 text-xs">—</span>
            </td>
            <td class="px-4 py-3 text-gray-600">{{ patient.phone || '—' }}</td>
            <td class="px-4 py-3 text-gray-500 text-xs">{{ formatDate(patient.created_at) }}</td>
            <td class="px-4 py-3">
              <AppBadge
                v-if="patient.is_archived"
                label="Archivé"
                color="bg-gray-100 text-gray-500"
              />
              <AppBadge
                v-else
                label="Actif"
                color="bg-green-100 text-green-700"
                :dot="true"
              />
            </td>
            <td class="px-4 py-3">
              <RouterLink
                :to="`/patients/${patient.id}`"
                class="text-blue-600 hover:text-blue-800 text-xs font-medium"
              >
                Voir →
              </RouterLink>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
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
