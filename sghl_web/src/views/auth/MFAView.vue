<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '@/layouts/AuthLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useMFA } from '@/controllers/useAuth'
import { useAuthStore } from '@/stores/auth.store'

const { loading, error, submit } = useMFA()
const auth = useAuthStore()
const router = useRouter()
const digits = ref(['', '', '', '', '', ''])
const inputs = ref([])

onMounted(() => {
  if (!auth.mfaPending) {
    router.push({ name: 'login' })
    return
  }
  inputs.value[0]?.focus()
})

function onInput(index, event) {
  const val = event.target.value.replace(/\D/g, '')
  digits.value[index] = val.slice(-1)
  if (val && index < 5) {
    inputs.value[index + 1]?.focus()
  }
  if (digits.value.every((d) => d !== '')) {
    handleSubmit()
  }
}

function onKeydown(index, event) {
  if (event.key === 'Backspace' && !digits.value[index] && index > 0) {
    inputs.value[index - 1]?.focus()
  }
}

function onPaste(event) {
  const text = event.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
  text.split('').forEach((char, i) => {
    digits.value[i] = char
  })
  if (text.length === 6) handleSubmit()
}

function handleSubmit() {
  const token = digits.value.join('')
  if (token.length === 6) submit(token)
}
</script>

<template>
  <AuthLayout>
    <div class="text-center mb-6">
      <div class="inline-flex items-center justify-center w-12 h-12 bg-blue-100 rounded-xl mb-3">
        <svg class="w-6 h-6 text-blue-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
      </div>
      <h2 class="text-xl font-bold text-gray-900">Vérification en deux étapes</h2>
      <p class="text-sm text-gray-500 mt-1">
        Saisissez le code à 6 chiffres de votre application d'authentification
      </p>
    </div>

    <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

    <div class="flex gap-2 justify-center mb-6" @paste.prevent="onPaste">
      <input
        v-for="(_, i) in digits"
        :key="i"
        :ref="(el) => (inputs[i] = el)"
        v-model="digits[i]"
        type="text"
        inputmode="numeric"
        maxlength="1"
        @input="onInput(i, $event)"
        @keydown="onKeydown(i, $event)"
        :class="[
          'w-11 h-12 text-center text-lg font-bold rounded-lg border-2 transition-colors',
          'focus:outline-none focus:border-blue-500',
          digits[i] ? 'border-blue-400 bg-blue-50' : 'border-gray-300',
        ]"
      />
    </div>

    <AppButton :loading="loading" full @click="handleSubmit" :disabled="digits.join('').length < 6">
      Vérifier
    </AppButton>

    <button
      @click="$router.push({ name: 'login' })"
      class="mt-4 w-full text-sm text-gray-500 hover:text-gray-700 text-center"
    >
      ← Retour à la connexion
    </button>
  </AuthLayout>
</template>
