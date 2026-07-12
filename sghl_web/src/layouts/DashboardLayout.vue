<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth.store'
import { ROLE_LABELS, ROLE_COLORS, ROLE_GRADIENT } from '@/models/auth.model'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()
const sidebarOpen = ref(true)

const navItems = computed(() => {
  const role = auth.currentRole
  const all = [
    { to: '/dashboard', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6', label: 'Tableau de bord', roles: ['ADMIN', 'DOCTOR', 'NURSE', 'ACCOUNTANT', 'OTHER'] },
    { to: '/patients', icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z', label: 'Patients', roles: ['ADMIN', 'DOCTOR', 'NURSE', 'RECEPTIONIST', 'LABTECH', 'OTHER'] },
    { to: '/consultations', icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2', label: 'Consultations', roles: ['ADMIN', 'DOCTOR'] },
    { to: '/hospitalisation', icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4', label: 'Hospitalisation', roles: ['ADMIN', 'DOCTOR', 'NURSE', 'RECEPTIONIST'] },
    { to: '/soins', icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z', label: 'Soins', roles: ['ADMIN', 'NURSE'] },
    { to: '/laboratoire', icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z', label: 'Laboratoire', roles: ['ADMIN', 'DOCTOR', 'BIOLOGIST', 'LABTECH'] },
    { to: '/pharmacie', icon: 'M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z', label: 'Pharmacie', roles: ['ADMIN', 'PHARMACIST', 'DOCTOR'] },
    { to: '/facturation', icon: 'M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z', label: 'Facturation', roles: ['ADMIN', 'ACCOUNTANT', 'RECEPTIONIST'] },
    { to: '/rendez-vous', icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z', label: 'Rendez-vous', roles: ['ADMIN', 'DOCTOR', 'RECEPTIONIST', 'PATIENT', 'OTHER'] },
    { to: '/medecins', icon: 'M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zM19.4 14.6a7.97 7.97 0 00-14.8 0', label: 'Médecins', roles: ['ADMIN', 'DOCTOR', 'RECEPTIONIST'] },
    { to: '/rh', icon: 'M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z', label: 'Ressources Humaines', roles: ['ADMIN'] },
    { to: '/utilisateurs', icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z', label: 'Utilisateurs', roles: ['ADMIN'] },
    { to: '/messages', icon: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z', label: 'Messagerie', roles: ['ADMIN', 'DOCTOR', 'NURSE', 'PATIENT'] },
    { to: '/export', icon: 'M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z', label: 'Export Excel', roles: ['ADMIN'] },
  ]
  return all.filter((item) => item.roles.includes(role))
})

function isActive(path) {
  return route.path.startsWith(path)
}

function logout() {
  auth.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <div class="flex h-screen bg-gray-50 overflow-hidden">
    <!-- Sidebar -->
    <aside
      :class="[
        'flex flex-col bg-white border-r border-gray-200 transition-all duration-300',
        sidebarOpen ? 'w-64' : 'w-16',
      ]"
    >
      <!-- Logo + Role header -->
      <div :class="['bg-linear-to-br px-4 py-5 shrink-0', ROLE_GRADIENT[auth.currentRole] || 'from-blue-700 to-blue-800']">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center shrink-0 border border-white/30">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </div>
          <span v-if="sidebarOpen" class="font-bold text-white text-lg">SGHL</span>
        </div>
        <div v-if="sidebarOpen" class="mt-3 flex items-center gap-2">
          <div class="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center text-white font-bold text-xs border border-white/30">
            {{ auth.fullName?.charAt(0)?.toUpperCase() || 'U' }}
          </div>
          <div class="min-w-0">
            <p class="text-xs font-semibold text-white truncate">{{ auth.fullName }}</p>
            <p class="text-xs text-white/70">{{ ROLE_LABELS[auth.currentRole] }}</p>
          </div>
        </div>
      </div>

      <!-- Nav -->
      <nav class="flex-1 overflow-y-auto px-2 py-3 space-y-0.5">
        <RouterLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          :class="[
            'flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium transition-all',
            isActive(item.to)
              ? 'bg-blue-50 text-blue-700 shadow-sm'
              : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900',
          ]"
        >
          <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon" />
          </svg>
          <span v-if="sidebarOpen" class="truncate">{{ item.label }}</span>
        </RouterLink>
      </nav>

      <!-- User footer -->
      <div class="border-t border-gray-200 p-2 shrink-0">
        <RouterLink
          to="/profil"
          :class="[
            'flex items-center gap-3 px-3 py-2 rounded-xl text-sm transition-colors',
            isActive('/profil') ? 'bg-blue-50 text-blue-700' : 'text-gray-600 hover:bg-gray-100',
          ]"
        >
          <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
          <span v-if="sidebarOpen" class="truncate">Mon profil</span>
        </RouterLink>
        <button
          @click="logout"
          class="mt-0.5 flex items-center gap-3 px-3 py-2 w-full rounded-xl text-sm text-red-600 hover:bg-red-50 transition-colors"
        >
          <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          <span v-if="sidebarOpen">Déconnexion</span>
        </button>
      </div>
    </aside>

    <!-- Main -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Topbar -->
      <header class="bg-white border-b border-gray-200 px-5 py-3 flex items-center gap-3 shrink-0">
        <button
          @click="sidebarOpen = !sidebarOpen"
          class="p-1.5 rounded-xl hover:bg-gray-100 text-gray-500 transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
        <div class="flex-1" />
        <!-- Role badge -->
        <span :class="['hidden sm:inline-flex items-center text-xs px-2.5 py-1 rounded-full font-semibold', ROLE_COLORS[auth.currentRole]]">
          {{ ROLE_LABELS[auth.currentRole] }}
        </span>
        <RouterLink to="/profil" class="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900">
          <div :class="['w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs text-white bg-linear-to-br', ROLE_GRADIENT[auth.currentRole] || 'from-blue-600 to-blue-700']">
            {{ auth.fullName?.charAt(0)?.toUpperCase() || 'U' }}
          </div>
          <span class="hidden sm:inline font-medium">{{ auth.fullName }}</span>
        </RouterLink>
      </header>

      <!-- Page content -->
      <main class="flex-1 overflow-y-auto p-6">
        <slot />
      </main>
    </div>
  </div>
</template>
