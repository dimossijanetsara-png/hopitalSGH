<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '@/layouts/AuthLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { authService } from '@/services/auth.service'

const router = useRouter()

const loading = ref(false)
const error = ref(null)
const success = ref(false)
const showPassword = ref(false)

const form = ref({
  first_name: '',
  last_name: '',
  email: '',
  password: '',
  phone: '',
})

async function handleSubmit() {
  error.value = null
  loading.value = true
  try {
    await authService.setupFirstAdmin({ ...form.value, role: 'ADMIN' })
    success.value = true
    setTimeout(() => router.push({ name: 'login' }), 2500)
  } catch (e) {
    const data = e.response?.data
    if (Array.isArray(data)) {
      error.value = data.map((err) => err.msg.replace(/^Value error,\s*/i, '')).join(' · ')
    } else {
      error.value = data?.detail || 'Erreur lors de la création du compte.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthLayout>
    <!-- Success -->
    <template v-if="success">
      <div class="text-center py-8">
        <div class="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-5">
          <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Compte créé !</h2>
        <p class="text-gray-500">Redirection vers la connexion…</p>
      </div>
    </template>

    <!-- Form -->
    <template v-else>
      <div class="mb-8">
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-violet-100 text-violet-700 text-xs font-semibold mb-4">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          Configuration initiale
        </div>
        <h2 class="text-3xl font-bold text-gray-900 mb-1">Superutilisateur</h2>
        <p class="text-gray-500">Créez le compte administrateur principal de SGHL.</p>
      </div>

      <AppAlert v-if="error" type="error" :message="error" class="mb-5" />

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div class="grid grid-cols-2 gap-3">
          <AppInput v-model="form.first_name" label="Prénom" required placeholder="Jean" />
          <AppInput v-model="form.last_name" label="Nom" required placeholder="Dupont" />
        </div>

        <AppInput
          v-model="form.email"
          label="Adresse e-mail"
          type="email"
          required
          placeholder="admin@sghl.com"
        />

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-medium text-gray-700">
            Mot de passe <span class="text-red-500">*</span>
          </label>
          <div class="relative">
            <input
              v-model="form.password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Min. 10 car. · 1 majuscule · 1 chiffre"
              required
              class="w-full px-4 py-2.5 pr-11 text-sm rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-300 focus:border-violet-400 bg-white transition"
            />
            <button
              type="button"
              @click="showPassword = !showPassword"
              class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  v-if="!showPassword"
                  stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                />
                <path
                  v-else
                  stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
                />
              </svg>
            </button>
          </div>
          <p class="text-xs text-gray-400">Min. 10 caractères · 1 majuscule · 1 chiffre</p>
        </div>

        <AppInput v-model="form.phone" label="Téléphone" placeholder="+242 06 XXX XX XX" />

        <AppButton type="submit" :loading="loading" full size="lg" class="!py-3 !rounded-xl">
          Créer le compte administrateur
        </AppButton>
      </form>

      <p class="mt-5 text-center text-sm text-gray-500">
        <RouterLink :to="{ name: 'login' }" class="text-blue-600 font-medium hover:underline">
          ← Retour à la connexion
        </RouterLink>
      </p>
    </template>
  </AuthLayout>
</template>
