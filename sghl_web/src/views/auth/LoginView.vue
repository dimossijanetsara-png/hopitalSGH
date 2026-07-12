<script setup>
import { ref, onMounted } from 'vue'
import AuthLayout from '@/layouts/AuthLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useLogin } from '@/controllers/useAuth'
import { authService } from '@/services/auth.service'

const { loading, error, submit } = useLogin()

const form = ref({ email: '', password: '' })
const showPassword = ref(false)
const setupDone = ref(true)

onMounted(async () => {
  try {
    const { data } = await authService.setupStatus()
    setupDone.value = data.setup_done
  } catch {
    /* ignore */
  }
})

function handleSubmit() {
  submit(form.value)
}
</script>

<template>
  <AuthLayout>
    <!-- Header -->
    <div class="mb-8">
      <h2 class="text-3xl font-bold text-gray-900 mb-1">Connexion</h2>
      <p class="text-gray-500">Accédez à votre espace de travail SGHL</p>
    </div>

    <!-- First-time setup notice -->
    <div
      v-if="setupDone === false"
      class="mb-5 flex items-start gap-3 p-4 rounded-xl bg-violet-50 border border-violet-200"
    >
      <div class="w-8 h-8 rounded-full bg-violet-100 flex items-center justify-center shrink-0 mt-0.5">
        <svg class="w-4 h-4 text-violet-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <div>
        <p class="text-sm font-semibold text-violet-800">Premier démarrage</p>
        <p class="text-xs text-violet-600 mt-0.5">Aucun compte administrateur n'existe encore.</p>
        <RouterLink
          :to="{ name: 'setup-admin' }"
          class="mt-1.5 inline-block text-xs font-semibold text-violet-700 underline hover:text-violet-900"
        >
          Créer le compte Superutilisateur →
        </RouterLink>
      </div>
    </div>

    <AppAlert v-if="error" type="error" :message="error" class="mb-5" />

    <form @submit.prevent="handleSubmit" class="space-y-5">
      <AppInput
        v-model="form.email"
        label="Adresse e-mail"
        type="email"
        placeholder="vous@sghl.com"
        required
      />

      <div class="flex flex-col gap-1.5">
        <label class="text-sm font-medium text-gray-700">
          Mot de passe <span class="text-red-500">*</span>
        </label>
        <div class="relative">
          <input
            v-model="form.password"
            :type="showPassword ? 'text' : 'password'"
            placeholder="••••••••••"
            required
            class="w-full px-4 py-2.5 pr-11 text-sm rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400 bg-white transition"
          />
          <button
            type="button"
            @click="showPassword = !showPassword"
            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
      </div>

      <AppButton type="submit" :loading="loading" full size="lg" class="!py-3 !text-base !rounded-xl">
        Se connecter
      </AppButton>
    </form>

    <!-- Divider -->
    <div class="my-6 flex items-center gap-3">
      <div class="flex-1 h-px bg-gray-200"></div>
      <span class="text-xs text-gray-400">ou</span>
      <div class="flex-1 h-px bg-gray-200"></div>
    </div>

    <!-- Register CTA -->
    <div class="rounded-xl border border-gray-200 bg-white p-5 text-center shadow-sm">
      <p class="text-sm text-gray-600 mb-3">Pas encore de compte ?</p>
      <RouterLink
        :to="{ name: 'register' }"
        class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-linear-to-r from-blue-600 to-teal-500 text-white text-sm font-semibold hover:opacity-90 transition shadow"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
        </svg>
        S'inscrire sur SGHL
      </RouterLink>
    </div>
  </AuthLayout>
</template>
