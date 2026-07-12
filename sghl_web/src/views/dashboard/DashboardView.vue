<script setup>
import { computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import KpiCard from '@/components/dashboard/KpiCard.vue'
import OccupancyGauge from '@/components/dashboard/OccupancyGauge.vue'
import HospitalisationChart from '@/components/dashboard/HospitalisationChart.vue'
import RevenueChart from '@/components/dashboard/RevenueChart.vue'
import QuickActions from '@/components/dashboard/QuickActions.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { useKpis, useHospitalisationStats, useRevenueStats } from '@/controllers/useDashboard'
import { useAuthStore } from '@/stores/auth.store'
import { KPI_DEFINITIONS } from '@/models/dashboard.model'

const auth = useAuthStore()
const { kpis, loading: kpiLoading, refetch } = useKpis()
const { stats: hospitStats, loading: hospitLoading } = useHospitalisationStats()
const { stats: revenueStats, loading: revenueLoading } = useRevenueStats()

const today = computed(() =>
  new Intl.DateTimeFormat('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(new Date()),
)

const STATUS_LABELS = {
  ACTIVE: 'En cours',
  DISCHARGED: 'Sortis',
  TRANSFERRED: 'Transférés',
  DECEASED: 'Décédés',
  PLANNED: 'Planifiés',
}
const STATUS_COLORS = {
  ACTIVE: 'bg-blue-500',
  DISCHARGED: 'bg-emerald-500',
  TRANSFERRED: 'bg-orange-400',
  DECEASED: 'bg-gray-400',
  PLANNED: 'bg-purple-500',
}

const hospitTotal = computed(() =>
  (hospitStats.value?.by_status || []).reduce((acc, item) => acc + (item.count || 0), 0),
)
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6 bg-linear-to-r from-blue-600 to-blue-700 rounded-2xl px-6 py-5 text-white shadow-sm">
      <div>
        <p class="text-blue-200 text-xs font-medium uppercase tracking-widest mb-0.5">Tableau de bord</p>
        <h1 class="text-xl font-bold leading-snug">
          Bonjour, {{ auth.user?.first_name || auth.user?.username }} 👋
        </h1>
        <p class="text-blue-200 text-sm mt-0.5 capitalize">{{ today }}</p>
      </div>
      <button
        @click="refetch"
        class="p-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white transition-colors"
        title="Actualiser les données"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
          />
        </svg>
      </button>
    </div>

    <!-- KPI Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-6">
      <KpiCard
        v-for="kpi in KPI_DEFINITIONS"
        :key="kpi.key"
        :label="kpi.label"
        :value="kpi.format(kpis?.[kpi.key])"
        :icon="kpi.icon"
        :color="kpi.color"
        :loading="kpiLoading"
        :sub="kpi.key === 'available_beds' ? `sur ${kpis?.total_beds ?? 0} lits` : ''"
      />
    </div>

    <!-- Row 2: Gauge + Statuts + Accès rapide -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-4">
      <!-- Jauge occupation -->
      <div class="bg-white rounded-xl border border-gray-200 p-5 flex flex-col items-center">
        <h3 class="text-sm font-semibold text-gray-700 mb-3 self-start">Occupation des lits</h3>
        <div v-if="kpiLoading" class="py-6"><AppSpinner /></div>
        <OccupancyGauge
          v-else
          :occupied="kpis?.occupied_beds ?? 0"
          :total="kpis?.total_beds ?? 0"
        />
        <div class="mt-4 w-full grid grid-cols-3 gap-2 text-center text-xs">
          <div class="bg-green-50 rounded-lg p-2">
            <p class="font-bold text-green-700">{{ kpis?.available_beds ?? 0 }}</p>
            <p class="text-gray-500">Disponibles</p>
          </div>
          <div class="bg-red-50 rounded-lg p-2">
            <p class="font-bold text-red-600">{{ kpis?.occupied_beds ?? 0 }}</p>
            <p class="text-gray-500">Occupés</p>
          </div>
          <div class="bg-gray-50 rounded-lg p-2">
            <p class="font-bold text-gray-700">{{ kpis?.total_beds ?? 0 }}</p>
            <p class="text-gray-500">Total</p>
          </div>
        </div>
      </div>

      <!-- Statuts hospitalisations -->
      <div class="bg-white rounded-xl border border-gray-200 p-5">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-sm font-semibold text-gray-700">Statuts hospitalisations</h3>
          <span v-if="hospitTotal" class="text-xs bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full font-medium">
            {{ hospitTotal }} total
          </span>
        </div>
        <div v-if="hospitLoading" class="flex justify-center py-6"><AppSpinner /></div>
        <div v-else class="space-y-3">
          <template v-if="hospitStats?.by_status?.length">
            <div
              v-for="item in hospitStats.by_status"
              :key="item.status"
              class="flex items-center gap-3"
            >
              <div class="flex items-center gap-1.5 w-28 shrink-0 min-w-0">
                <span
                  class="w-2 h-2 rounded-full shrink-0"
                  :class="STATUS_COLORS[item.status] || 'bg-gray-400'"
                />
                <span class="text-xs text-gray-600 truncate">
                  {{ STATUS_LABELS[item.status] || item.status }}
                </span>
              </div>
              <div class="flex-1 h-2 rounded-full bg-gray-100 overflow-hidden">
                <div
                  class="h-full rounded-full transition-all duration-700"
                  :class="STATUS_COLORS[item.status] || 'bg-blue-500'"
                  :style="{ width: `${Math.min(100, (item.count / Math.max(1, hospitTotal)) * 100)}%` }"
                />
              </div>
              <span class="text-xs font-bold text-gray-700 w-6 text-right tabular-nums">
                {{ item.count }}
              </span>
            </div>
          </template>
          <div v-else class="flex flex-col items-center justify-center py-6 text-gray-400">
            <svg class="w-8 h-8 mb-2 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <p class="text-xs">Aucune donnée disponible</p>
          </div>
        </div>
      </div>

      <!-- Accès rapide -->
      <QuickActions />
    </div>

    <!-- Row 3: Graphiques -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <div
        v-if="hospitLoading"
        class="bg-white rounded-xl border border-gray-200 p-5 flex justify-center items-center h-48"
      >
        <AppSpinner />
      </div>
      <HospitalisationChart v-else :stats="hospitStats" />

      <div
        v-if="revenueLoading"
        class="bg-white rounded-xl border border-gray-200 p-5 flex justify-center items-center h-48"
      >
        <AppSpinner />
      </div>
      <RevenueChart v-else :stats="revenueStats" />
    </div>
  </DashboardLayout>
</template>
