<script setup>
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth.store'

const auth = useAuthStore()

const actions = computed(() => {
  const role = auth.currentRole
  const all = [
    { to: '/patients/nouveau', label: 'Nouveau patient', icon: 'M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z', roles: ['ADMIN', 'RECEPTIONIST', 'DOCTOR'] },
    { to: '/hospitalisation/admissions/nouvelle', label: 'Admettre un patient', icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4', roles: ['ADMIN', 'RECEPTIONIST', 'DOCTOR'] },
    { to: '/consultations/nouvelle', label: 'Nouvelle consultation', icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2', roles: ['ADMIN', 'DOCTOR'] },
    { to: { path: '/laboratoire', query: { create: '1' } }, label: 'Commande labo', icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z', roles: ['ADMIN', 'DOCTOR', 'BIOLOGIST'] },
    { to: { path: '/rendez-vous', query: { create: '1' } }, label: 'Prendre un RDV', icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z', roles: ['ADMIN', 'RECEPTIONIST', 'DOCTOR', 'PATIENT'] },
    { to: { path: '/facturation', query: { create: '1' } }, label: 'Créer une facture', icon: 'M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z', roles: ['ADMIN', 'ACCOUNTANT', 'RECEPTIONIST'] },
  ]
  return all.filter((a) => a.roles.includes(role))
})
</script>

<template>
  <div class="bg-white rounded-xl border border-gray-200 p-5">
    <h3 class="text-sm font-semibold text-gray-700 mb-4">Accès rapide</h3>
    <div class="grid grid-cols-2 gap-3">
      <RouterLink
        v-for="action in actions"
        :key="action.to"
        :to="action.to"
        class="flex items-center gap-3 p-3 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-colors group"
      >
        <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center group-hover:bg-blue-200 transition-colors">
          <svg class="w-4 h-4 text-blue-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="action.icon" />
          </svg>
        </div>
        <span class="text-xs font-medium text-gray-700 leading-tight">{{ action.label }}</span>
      </RouterLink>
    </div>
  </div>
</template>
