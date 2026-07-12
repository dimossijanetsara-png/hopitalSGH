<script setup>
import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppInput from '@/components/ui/AppInput.vue'
import { authService } from '@/services/auth.service'

const qc = useQueryClient()

// ── List ──────────────────────────────────────────────────────────────────────
const search = ref('')
const roleFilter = ref('')

const { data, isLoading } = useQuery({
  queryKey: ['users'],
  queryFn: async () => (await authService.listUsers()).data,
})

const users = computed(() => {
  let list = data.value || []
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(
      (u) =>
        u.first_name.toLowerCase().includes(q) ||
        u.last_name.toLowerCase().includes(q) ||
        u.email.toLowerCase().includes(q),
    )
  }
  if (roleFilter.value) list = list.filter((u) => u.role === roleFilter.value)
  return list
})

// ── Toggle active ─────────────────────────────────────────────────────────────
const { mutate: toggleActive } = useMutation({
  mutationFn: (id) => authService.toggleUser(id),
  onSuccess: () => qc.invalidateQueries({ queryKey: ['users'] }),
})

// ── Create ────────────────────────────────────────────────────────────────────
const showCreate = ref(false)
const createError = ref(null)
const creating = ref(false)
const form = ref({
  first_name: '',
  last_name: '',
  email: '',
  password: '',
  role: 'DOCTOR',
  phone: '',
})

const ROLES = [
  { value: 'ADMIN', label: 'Administrateur' },
  { value: 'DOCTOR', label: 'Médecin' },
  { value: 'NURSE', label: 'Infirmier(e)' },
  { value: 'BIOLOGIST', label: 'Biologiste' },
  { value: 'PHARMACIST', label: 'Pharmacien(ne)' },
  { value: 'RECEPTIONIST', label: 'Réceptionniste' },
  { value: 'ACCOUNTANT', label: 'Comptable' },
  { value: 'PATIENT', label: 'Patient' },
]

const ROLE_COLORS = {
  ADMIN: 'bg-red-100 text-red-700',
  DOCTOR: 'bg-blue-100 text-blue-700',
  NURSE: 'bg-green-100 text-green-700',
  BIOLOGIST: 'bg-purple-100 text-purple-700',
  PHARMACIST: 'bg-yellow-100 text-yellow-700',
  RECEPTIONIST: 'bg-pink-100 text-pink-700',
  ACCOUNTANT: 'bg-orange-100 text-orange-700',
  PATIENT: 'bg-gray-100 text-gray-600',
}

async function handleCreate() {
  createError.value = null
  creating.value = true
  try {
    await authService.register({ ...form.value })
    await qc.invalidateQueries({ queryKey: ['users'] })
    showCreate.value = false
    form.value = { first_name: '', last_name: '', email: '', password: '', role: 'DOCTOR', phone: '' }
  } catch (e) {
    const data = e.response?.data
    if (Array.isArray(data)) {
      createError.value = data.map((err) => err.msg.replace(/^Value error,\s*/i, '')).join(' · ')
    } else {
      createError.value = data?.detail || 'Erreur lors de la création.'
    }
  } finally {
    creating.value = false
  }
}

function roleLabel(v) {
  return ROLES.find((r) => r.value === v)?.label || v
}

function initials(u) {
  return `${u.first_name[0] || ''}${u.last_name[0] || ''}`.toUpperCase()
}
</script>

<template>
  <DashboardLayout>
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Gestion des utilisateurs</h1>
        <p class="text-sm text-gray-500 mt-0.5">Créer et gérer les comptes du personnel</p>
      </div>
      <AppButton @click="showCreate = true">
        <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Nouvel utilisateur
      </AppButton>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 mb-5">
      <input
        v-model="search"
        type="text"
        placeholder="Rechercher nom, email…"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 w-60"
      />
      <select
        v-model="roleFilter"
        class="px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      >
        <option value="">Tous les rôles</option>
        <option v-for="r in ROLES" :key="r.value" :value="r.value">{{ r.label }}</option>
      </select>
      <span class="ml-auto self-center text-sm text-gray-400">{{ users.length }} utilisateur(s)</span>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div v-if="isLoading" class="flex justify-center py-16"><AppSpinner size="lg" /></div>
      <div v-else-if="!users.length" class="text-center py-16 text-gray-400">
        <svg class="w-12 h-12 mx-auto mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        <p>Aucun utilisateur trouvé</p>
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Utilisateur</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Email</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Rôle</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Téléphone</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">MFA</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Statut</th>
            <th class="text-right px-4 py-3"></th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50 transition-colors">
            <td class="px-4 py-3">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-xs font-bold shrink-0">
                  {{ initials(user) }}
                </div>
                <span class="font-medium text-gray-800">{{ user.first_name }} {{ user.last_name }}</span>
              </div>
            </td>
            <td class="px-4 py-3 text-gray-500 text-xs">{{ user.email }}</td>
            <td class="px-4 py-3">
              <AppBadge :color-class="ROLE_COLORS[user.role] || 'bg-gray-100 text-gray-600'">
                {{ roleLabel(user.role) }}
              </AppBadge>
            </td>
            <td class="px-4 py-3 text-gray-500 text-xs">{{ user.phone || '–' }}</td>
            <td class="px-4 py-3 text-center">
              <span v-if="user.mfa_enabled" class="text-green-600 text-xs font-medium">Activé</span>
              <span v-else class="text-gray-400 text-xs">–</span>
            </td>
            <td class="px-4 py-3 text-center">
              <AppBadge :color-class="user.is_active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-600'">
                {{ user.is_active ? 'Actif' : 'Inactif' }}
              </AppBadge>
            </td>
            <td class="px-4 py-3 text-right">
              <button
                class="text-xs font-medium transition-colors"
                :class="user.is_active ? 'text-red-500 hover:text-red-700' : 'text-green-600 hover:text-green-800'"
                @click="toggleActive(user.id)"
              >
                {{ user.is_active ? 'Désactiver' : 'Réactiver' }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Create modal -->
    <AppModal :open="showCreate" title="Nouvel utilisateur" size="md" @close="showCreate = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />

        <div class="grid grid-cols-2 gap-4">
          <AppInput v-model="form.first_name" label="Prénom" required placeholder="Jean" />
          <AppInput v-model="form.last_name" label="Nom" required placeholder="Dupont" />
        </div>

        <AppInput v-model="form.email" label="Email" type="email" required placeholder="jean.dupont@sghl.com" />

        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">
            Mot de passe <span class="text-red-500">*</span>
          </label>
          <input
            v-model="form.password"
            type="password"
            placeholder="Min. 10 caractères, 1 majuscule, 1 chiffre"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
          />
          <p class="text-xs text-gray-400 mt-1">Min. 10 caractères · 1 majuscule · 1 chiffre</p>
        </div>

        <div>
          <label class="text-sm font-medium text-gray-700 block mb-2">
            Rôle <span class="text-red-500">*</span>
          </label>
          <div class="grid grid-cols-2 gap-2">
            <label
              v-for="r in ROLES"
              :key="r.value"
              :class="[
                'flex items-center gap-2 px-3 py-2 rounded-lg border cursor-pointer text-sm transition-colors',
                form.role === r.value
                  ? 'border-blue-500 bg-blue-50 text-blue-700 font-medium'
                  : 'border-gray-200 hover:border-gray-300 text-gray-700',
              ]"
            >
              <input v-model="form.role" type="radio" :value="r.value" class="hidden" />
              {{ r.label }}
            </label>
          </div>
        </div>

        <AppInput v-model="form.phone" label="Téléphone" placeholder="+242 06 XXX XX XX" />
      </div>

      <template #footer>
        <AppButton variant="secondary" @click="showCreate = false">Annuler</AppButton>
        <AppButton
          :loading="creating"
          :disabled="!form.email || !form.password || !form.first_name || !form.last_name"
          @click="handleCreate"
        >
          Créer le compte
        </AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
