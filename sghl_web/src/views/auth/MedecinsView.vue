<script setup>
import { ref, computed } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppPagination from '@/components/ui/AppPagination.vue'
import { useQuery } from '@tanstack/vue-query'
import { authService } from '@/services/auth.service'
import { hrService } from '@/services/hr.service'
import { exportToExcel, STAFF_COLUMNS } from '@/utils/export'
import { useAuthStore } from '@/stores/auth.store'

const auth = useAuthStore()

// ─── Liste des médecins (users avec role=DOCTOR) ─────────────────────────────
const search = ref('')
const page = ref(1)

const { data: usersData, isLoading: usersLoading } = useQuery({
  queryKey: ['users', 'DOCTOR'],
  queryFn: async () => {
    const { data } = await authService.listUsers({ role: 'DOCTOR' })
    return data
  },
})

const doctors = computed(() => {
  const list = usersData.value || []
  if (!search.value) return list
  const q = search.value.toLowerCase()
  return list.filter((d) =>
    `${d.first_name} ${d.last_name} ${d.email}`.toLowerCase().includes(q),
  )
})

const PAGE_SIZE = 12
const totalPages = computed(() => Math.ceil(doctors.value.length / PAGE_SIZE))
const paginated = computed(() => doctors.value.slice((page.value - 1) * PAGE_SIZE, page.value * PAGE_SIZE))

// ─── StaffProfiles des médecins (pour spécialisation) ────────────────────────
const { data: staffData } = useQuery({
  queryKey: ['staff', 'DOCTOR'],
  queryFn: async () => {
    const { data } = await hrService.listStaff({ role: 'DOCTOR' })
    return data
  },
})

const staffMap = computed(() => {
  const map = {}
  const list = staffData.value?.results || staffData.value || []
  list.forEach((s) => { map[s.user_id] = s })
  return map
})

// ─── Modal création utilisateur médecin ──────────────────────────────────────
const showCreateModal = ref(false)
const createError = ref(null)
const creating = ref(false)
const createForm = ref({
  first_name: '', last_name: '', email: '',
  password: 'Medecin2024!', role: 'DOCTOR', phone: '',
})

async function handleCreate() {
  creating.value = true
  createError.value = null
  try {
    await authService.register(createForm.value)
    showCreateModal.value = false
    createForm.value = { first_name: '', last_name: '', email: '', password: 'Medecin2024!', role: 'DOCTOR', phone: '' }
  } catch (err) {
    createError.value = err.response?.data?.detail || 'Erreur lors de la création.'
  } finally {
    creating.value = false
  }
}

// ─── Export Excel ─────────────────────────────────────────────────────────────
function handleExport() {
  const list = staffData.value?.results || staffData.value || []
  if (list.length) {
    exportToExcel(list, STAFF_COLUMNS, 'medecins')
  } else {
    // Fallback: export users only
    const cols = [
      { header: 'Nom', key: 'last_name' },
      { header: 'Prénom', key: 'first_name' },
      { header: 'Email', key: 'email' },
      { header: 'Téléphone', key: 'phone' },
      { header: 'Actif', key: 'is_active', format: (v) => v ? 'Oui' : 'Non' },
    ]
    exportToExcel(doctors.value, cols, 'medecins')
  }
}

const SPECIALTY_COLORS = {
  Cardiologie: 'bg-red-100 text-red-700',
  Neurologie: 'bg-purple-100 text-purple-700',
  Pédiatrie: 'bg-yellow-100 text-yellow-700',
  Chirurgie: 'bg-orange-100 text-orange-700',
  Gynécologie: 'bg-pink-100 text-pink-700',
  Radiologie: 'bg-blue-100 text-blue-700',
  'Médecine générale': 'bg-green-100 text-green-700',
}

function specialtyColor(spec) {
  return SPECIALTY_COLORS[spec] || 'bg-gray-100 text-gray-600'
}

function initials(d) {
  return `${d.first_name?.[0] || ''}${d.last_name?.[0] || ''}`.toUpperCase()
}

const AVATAR_COLORS = [
  'bg-blue-500', 'bg-indigo-500', 'bg-purple-500',
  'bg-teal-500', 'bg-cyan-500', 'bg-emerald-500',
]
function avatarColor(d) {
  const code = (d.first_name?.charCodeAt(0) || 0) + (d.last_name?.charCodeAt(0) || 0)
  return AVATAR_COLORS[code % AVATAR_COLORS.length]
}
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Médecins</h1>
        <p class="text-sm text-gray-500 mt-0.5">Annuaire du corps médical</p>
      </div>
      <div class="flex gap-2">
        <AppButton variant="secondary" @click="handleExport">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Exporter Excel
        </AppButton>
        <AppButton v-if="auth.currentRole === 'ADMIN'" @click="showCreateModal = true">
          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nouveau médecin
        </AppButton>
      </div>
    </div>

    <!-- Barre de recherche + compteur -->
    <div class="flex items-center gap-4 mb-6">
      <div class="relative flex-1 max-w-xs">
        <svg class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <input
          v-model="search"
          type="text"
          placeholder="Rechercher un médecin…"
          class="pl-9 pr-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-full"
          @input="page = 1"
        />
      </div>
      <span class="text-sm text-gray-500">
        {{ doctors.length }} médecin{{ doctors.length !== 1 ? 's' : '' }}
      </span>
    </div>

    <!-- Loading -->
    <div v-if="usersLoading" class="flex justify-center py-20"><AppSpinner size="lg" /></div>

    <!-- Empty -->
    <div v-else-if="!doctors.length" class="text-center py-20 text-gray-400">
      <svg class="w-16 h-16 mx-auto mb-4 opacity-20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
          d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zM19.4 14.6a7.97 7.97 0 00-14.8 0" />
      </svg>
      <p class="text-sm">Aucun médecin trouvé</p>
    </div>

    <!-- Grille de cartes médecins -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <div
        v-for="doc in paginated"
        :key="doc.id"
        class="bg-white rounded-xl border border-gray-200 p-5 hover:shadow-md transition-shadow"
      >
        <!-- Avatar + nom -->
        <div class="flex items-center gap-3 mb-3">
          <div
            :class="['w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-sm shrink-0', avatarColor(doc)]"
          >
            {{ initials(doc) }}
          </div>
          <div class="min-w-0">
            <p class="font-semibold text-gray-900 truncate">Dr {{ doc.last_name }} {{ doc.first_name }}</p>
            <p class="text-xs text-gray-400 truncate">{{ doc.email }}</p>
          </div>
        </div>

        <!-- Spécialisation -->
        <div class="mb-3">
          <span
            v-if="staffMap[doc.id]?.specialization"
            :class="['text-xs px-2 py-0.5 rounded-full font-medium', specialtyColor(staffMap[doc.id].specialization)]"
          >
            {{ staffMap[doc.id].specialization }}
          </span>
          <span v-else class="text-xs text-gray-400">Spécialisation non renseignée</span>
        </div>

        <!-- Infos -->
        <div class="space-y-1 text-xs text-gray-500">
          <div v-if="doc.phone" class="flex items-center gap-1.5">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            {{ doc.phone }}
          </div>
          <div v-if="staffMap[doc.id]?.employee_number" class="flex items-center gap-1.5">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0" />
            </svg>
            Matricule : {{ staffMap[doc.id].employee_number }}
          </div>
          <div v-if="staffMap[doc.id]?.license_number" class="flex items-center gap-1.5">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
            </svg>
            N° {{ staffMap[doc.id].license_number }}
          </div>
        </div>

        <!-- Statut -->
        <div class="mt-3 pt-3 border-t border-gray-100">
          <AppBadge :color-class="doc.is_active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'">
            {{ doc.is_active ? 'Actif' : 'Inactif' }}
          </AppBadge>
          <span v-if="doc.mfa_enabled" class="ml-2 text-xs text-blue-600 font-medium">🔐 MFA</span>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="mt-6">
      <AppPagination :current-page="page" :total-pages="totalPages" :total-items="doctors.length" @change="page = $event" />
    </div>

    <!-- Modal création médecin -->
    <AppModal :open="showCreateModal" title="Nouveau médecin" size="md" @close="showCreateModal = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />
        <p class="text-sm text-gray-500">
          Un email avec un code OTP sera envoyé pour activer le compte.
        </p>
        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="createForm.first_name" label="Prénom" required />
          <AppInput v-model="createForm.last_name" label="Nom" required />
        </div>
        <AppInput v-model="createForm.email" label="Email professionnel" type="email" required />
        <AppInput v-model="createForm.phone" label="Téléphone" />
        <AppInput
          v-model="createForm.password"
          label="Mot de passe provisoire"
          type="text"
          helper="Minimum 10 caractères, 1 majuscule, 1 chiffre"
        />
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showCreateModal = false">Annuler</AppButton>
        <AppButton
          :loading="creating"
          :disabled="!createForm.first_name || !createForm.last_name || !createForm.email"
          @click="handleCreate"
        >
          Créer le compte
        </AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
