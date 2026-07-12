<script setup>
import { ref, watch } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useProfile } from '@/controllers/useAuth'
import { useAuthStore } from '@/stores/auth.store'
import { ROLE_LABELS, ROLE_COLORS } from '@/models/auth.model'

const auth = useAuthStore()
const { loading, error, success, updateProfile } = useProfile()

const form = ref({
  first_name: auth.user?.first_name || '',
  last_name: auth.user?.last_name || '',
  phone: auth.user?.phone || '',
})

watch(
  () => auth.user,
  (u) => {
    if (u) {
      form.value.first_name = u.first_name
      form.value.last_name = u.last_name
      form.value.phone = u.phone || ''
    }
  },
)

function handleSubmit() {
  updateProfile(form.value)
}
</script>

<template>
  <DashboardLayout>
    <div class="max-w-2xl mx-auto">
      <h1 class="text-2xl font-bold text-gray-900 mb-6">Mon profil</h1>

      <!-- Avatar + role -->
      <div class="bg-white rounded-xl border border-gray-200 p-6 mb-6 flex items-center gap-5">
        <div class="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-2xl">
          {{ auth.fullName?.charAt(0)?.toUpperCase() || 'U' }}
        </div>
        <div>
          <p class="text-lg font-semibold text-gray-900">{{ auth.fullName }}</p>
          <p class="text-sm text-gray-500 mb-1">{{ auth.user?.email }}</p>
          <span :class="['text-xs px-2 py-1 rounded-full font-medium', ROLE_COLORS[auth.currentRole]]">
            {{ ROLE_LABELS[auth.currentRole] }}
          </span>
        </div>
      </div>

      <!-- Form -->
      <div class="bg-white rounded-xl border border-gray-200 p-6 mb-4">
        <h2 class="text-base font-semibold text-gray-900 mb-4">Informations personnelles</h2>

        <AppAlert v-if="error" type="error" :message="error" class="mb-4" />
        <AppAlert v-if="success" type="success" message="Profil mis à jour avec succès." class="mb-4" />

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <AppInput v-model="form.first_name" label="Prénom" required />
            <AppInput v-model="form.last_name" label="Nom" required />
          </div>
          <AppInput
            :model-value="auth.user?.email"
            label="Adresse e-mail"
            type="email"
            disabled
            hint="L'adresse e-mail ne peut pas être modifiée."
          />
          <AppInput v-model="form.phone" label="Téléphone" type="tel" placeholder="+242 06 000 0000" />

          <div class="flex justify-end pt-2">
            <AppButton type="submit" :loading="loading">
              Enregistrer les modifications
            </AppButton>
          </div>
        </form>
      </div>

      <!-- Security links -->
      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <h2 class="text-base font-semibold text-gray-900 mb-4">Sécurité</h2>
        <div class="space-y-3">
          <RouterLink
            to="/changer-mot-de-passe"
            class="flex items-center justify-between p-3 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-colors group"
          >
            <div class="flex items-center gap-3">
              <svg class="w-5 h-5 text-gray-400 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
              </svg>
              <span class="text-sm font-medium text-gray-700">Changer le mot de passe</span>
            </div>
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </RouterLink>
          <RouterLink
            to="/configurer-mfa"
            class="flex items-center justify-between p-3 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-colors group"
          >
            <div class="flex items-center gap-3">
              <svg class="w-5 h-5 text-gray-400 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
              <div>
                <span class="text-sm font-medium text-gray-700">Authentification à deux facteurs</span>
                <span :class="['ml-2 text-xs px-1.5 py-0.5 rounded-full font-medium', auth.user?.mfa_enabled ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500']">
                  {{ auth.user?.mfa_enabled ? 'Activée' : 'Désactivée' }}
                </span>
              </div>
            </div>
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </RouterLink>
        </div>
      </div>
    </div>
  </DashboardLayout>
</template>
