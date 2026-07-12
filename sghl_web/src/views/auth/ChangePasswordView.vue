<script setup>
import { ref } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useChangePassword } from '@/controllers/useAuth'

const { loading, error, success, submit } = useChangePassword()

const form = ref({ old_password: '', new_password: '', confirm_password: '' })
const confirmError = ref('')

function handleSubmit() {
  confirmError.value = ''
  if (form.value.new_password !== form.value.confirm_password) {
    confirmError.value = 'Les mots de passe ne correspondent pas.'
    return
  }
  if (form.value.new_password.length < 10) {
    confirmError.value = 'Le mot de passe doit contenir au moins 10 caractères.'
    return
  }
  submit({ old_password: form.value.old_password, new_password: form.value.new_password })
}
</script>

<template>
  <DashboardLayout>
    <div class="max-w-lg mx-auto">
      <div class="flex items-center gap-3 mb-6">
        <RouterLink to="/profil" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </RouterLink>
        <h1 class="text-2xl font-bold text-gray-900">Changer le mot de passe</h1>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <AppAlert v-if="error" type="error" :message="error" class="mb-4" />
        <AppAlert
          v-if="success"
          type="success"
          message="Mot de passe modifié avec succès."
          class="mb-4"
        />

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <AppInput
            v-model="form.old_password"
            label="Mot de passe actuel"
            type="password"
            required
          />
          <AppInput
            v-model="form.new_password"
            label="Nouveau mot de passe"
            type="password"
            required
            hint="Minimum 10 caractères, avec chiffres et majuscules."
          />
          <AppInput
            v-model="form.confirm_password"
            label="Confirmer le nouveau mot de passe"
            type="password"
            required
            :error="confirmError"
          />

          <!-- Règles -->
          <ul class="text-xs text-gray-500 space-y-1 pl-4 list-disc">
            <li :class="form.new_password.length >= 10 ? 'text-green-600' : ''">
              Au moins 10 caractères
            </li>
            <li :class="/[A-Z]/.test(form.new_password) ? 'text-green-600' : ''">
              Au moins une lettre majuscule
            </li>
            <li :class="/[0-9]/.test(form.new_password) ? 'text-green-600' : ''">
              Au moins un chiffre
            </li>
          </ul>

          <div class="flex justify-end pt-2">
            <AppButton type="submit" :loading="loading">
              Modifier le mot de passe
            </AppButton>
          </div>
        </form>
      </div>
    </div>
  </DashboardLayout>
</template>
