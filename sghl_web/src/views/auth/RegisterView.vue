<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '@/layouts/AuthLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { ROLE_CARDS } from '@/models/auth.model'
import { authService } from '@/services/auth.service'
import { useAuthStore } from '@/stores/auth.store'

const router = useRouter()
const auth = useAuthStore()

// ── State ─────────────────────────────────────────────────────────────────────
const step = ref(1)             // 1 = role, 2 = form, 3 = otp
const selectedRole = ref(null)
const loading = ref(false)
const error = ref(null)
const showPassword = ref(false)

const form = ref({
  first_name: '',
  last_name: '',
  email: '',
  password: '',
  phone: '',
})

// Stored after successful registration for OTP + auto-login
const registeredEmail = ref('')
const storedPassword = ref('')
const devOtpCode = ref('')   // populated in dev mode from API response

// OTP
const otpCode = ref('')
const resendCooldown = ref(0)
let resendTimer = null

// ── Step 1 : Role selection ───────────────────────────────────────────────────
function selectRole(role) {
  selectedRole.value = role
}

// ── Step 2 : Registration form ────────────────────────────────────────────────
async function handleRegister() {
  error.value = null
  loading.value = true
  try {
    const { data } = await authService.registerPublic({
      ...form.value,
      role: selectedRole.value,
    })
    registeredEmail.value = form.value.email
    storedPassword.value = form.value.password
    // Extract dev OTP from detail message if present (DEBUG mode)
    const devMatch = data?.detail?.match(/\[DEV\] Code OTP\s*:\s*(\d{6})/)
    devOtpCode.value = devMatch ? devMatch[1] : ''
    startResendCooldown(120)
    step.value = 3
  } catch (e) {
    const data = e.response?.data
    if (Array.isArray(data)) {
      error.value = data.map((err) => err.msg.replace(/^Value error,\s*/i, '')).join(' · ')
    } else {
      error.value = data?.detail || 'Erreur lors de l\'inscription.'
    }
  } finally {
    loading.value = false
  }
}

// ── Step 3 : OTP verification + auto-login ────────────────────────────────────
async function handleVerify() {
  error.value = null
  if (otpCode.value.length !== 6) {
    error.value = 'Entrez le code à 6 chiffres reçu par email.'
    return
  }
  loading.value = true
  try {
    await authService.verifyOTP({ email: registeredEmail.value, otp_code: otpCode.value })
    // Auto-login with stored credentials
    const result = await auth.login({ email: registeredEmail.value, password: storedPassword.value })
    if (result.mfaRequired) {
      router.push({ name: 'mfa' })
    } else {
      // Redirect to role-specific dashboard
      const ROUTES = {
        DOCTOR: '/dashboard',
        NURSE: '/soins',
        BIOLOGIST: '/laboratoire',
        PHARMACIST: '/pharmacie',
        RECEPTIONIST: '/patients',
        ACCOUNTANT: '/facturation',
        PATIENT: '/rendez-vous',
        LABTECH: '/laboratoire',
        OTHER: '/dashboard',
      }
      router.push(ROUTES[selectedRole.value] || '/dashboard')
    }
  } catch (e) {
    const data = e.response?.data
    if (Array.isArray(data)) {
      error.value = data.map((err) => err.msg.replace(/^Value error,\s*/i, '')).join(' · ')
    } else {
      error.value = data?.detail || 'Code invalide ou expiré.'
    }
  } finally {
    loading.value = false
  }
}

async function resendOTP() {
  if (resendCooldown.value > 0) return
  error.value = null
  try {
    await authService.resendOTP({ email: registeredEmail.value })
    startResendCooldown(120)
  } catch (e) {
    error.value = e.response?.data?.detail || 'Impossible de renvoyer le code.'
  }
}

function startResendCooldown(seconds) {
  resendCooldown.value = seconds
  if (resendTimer) clearInterval(resendTimer)
  resendTimer = setInterval(() => {
    resendCooldown.value--
    if (resendCooldown.value <= 0) clearInterval(resendTimer)
  }, 1000)
}

function formatCooldown(s) {
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
}

// ── Helpers ───────────────────────────────────────────────────────────────────
const roleCard = (value) => ROLE_CARDS.find((r) => r.value === value)
</script>

<template>
  <AuthLayout>
    <!-- ── Step indicator ──────────────────────────────────────────────── -->
    <div class="flex items-center mb-8">
      <template v-for="n in 3" :key="n">
        <!-- Line before (except first) -->
        <div
          v-if="n > 1"
          :class="['flex-1 h-0.5 rounded-full', step > n - 1 ? 'bg-green-400' : 'bg-gray-200']"
        ></div>
        <!-- Circle -->
        <div
          :class="[
            'flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold transition-all shrink-0',
            step === n
              ? 'bg-blue-600 text-white shadow-lg shadow-blue-300'
              : step > n
              ? 'bg-green-500 text-white'
              : 'bg-gray-200 text-gray-400',
          ]"
        >
          <svg v-if="step > n" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
          <span v-else>{{ n }}</span>
        </div>
      </template>
    </div>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- Step 1 : Role selection                                              -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <template v-if="step === 1">
      <div class="mb-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-1">Qui êtes-vous ?</h2>
        <p class="text-gray-500 text-sm">Choisissez votre rôle au sein de l'établissement.</p>
      </div>

      <div class="grid grid-cols-3 gap-3">
        <button
          v-for="card in ROLE_CARDS"
          :key="card.value"
          type="button"
          @click="selectRole(card.value)"
          :class="[
            'relative flex flex-col items-center gap-2 p-3 rounded-2xl border-2 transition-all text-center',
            selectedRole === card.value
              ? 'border-blue-500 bg-blue-50 shadow-lg shadow-blue-100 scale-105'
              : 'border-gray-200 bg-white hover:border-gray-300 hover:shadow-md',
          ]"
        >
          <!-- Selected checkmark -->
          <div
            v-if="selectedRole === card.value"
            class="absolute top-1.5 right-1.5 w-5 h-5 rounded-full bg-blue-600 flex items-center justify-center"
          >
            <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </div>

          <!-- Icon -->
          <div :class="['w-10 h-10 rounded-xl flex items-center justify-center bg-linear-to-br', card.gradient]">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="card.icon" />
            </svg>
          </div>

          <p class="text-xs font-semibold text-gray-800 leading-tight">{{ card.label }}</p>
        </button>
      </div>

      <!-- Description of selected role -->
      <div
        v-if="selectedRole"
        class="mt-4 p-3 rounded-xl bg-blue-50 border border-blue-100 flex items-start gap-3"
      >
        <div :class="['w-8 h-8 rounded-lg flex items-center justify-center bg-linear-to-br shrink-0', roleCard(selectedRole)?.gradient]">
          <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="roleCard(selectedRole)?.icon" />
          </svg>
        </div>
        <div>
          <p class="text-sm font-semibold text-gray-900">{{ roleCard(selectedRole)?.label }}</p>
          <p class="text-xs text-gray-500">{{ roleCard(selectedRole)?.description }}</p>
        </div>
      </div>

      <AppButton
        :disabled="!selectedRole"
        full
        size="lg"
        class="mt-6 !py-3 !rounded-xl"
        @click="step = 2"
      >
        Continuer →
      </AppButton>

      <p class="mt-4 text-center text-sm text-gray-500">
        Déjà inscrit ?
        <RouterLink :to="{ name: 'login' }" class="text-blue-600 font-medium hover:underline">
          Se connecter
        </RouterLink>
      </p>
    </template>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- Step 2 : Registration form                                           -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <template v-else-if="step === 2">
      <div class="mb-6">
        <button type="button" @click="step = 1" class="flex items-center gap-1 text-sm text-gray-500 hover:text-gray-800 mb-3">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Retour
        </button>

        <!-- Role badge -->
        <div class="flex items-center gap-2 mb-3">
          <div :class="['w-7 h-7 rounded-lg flex items-center justify-center bg-linear-to-br', roleCard(selectedRole)?.gradient]">
            <svg class="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="roleCard(selectedRole)?.icon" />
            </svg>
          </div>
          <span class="text-sm font-semibold text-gray-700">{{ roleCard(selectedRole)?.label }}</span>
        </div>

        <h2 class="text-2xl font-bold text-gray-900 mb-1">Créez votre compte</h2>
        <p class="text-gray-500 text-sm">Renseignez vos informations personnelles.</p>
      </div>

      <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

      <form @submit.prevent="handleRegister" class="space-y-4">
        <div class="grid grid-cols-2 gap-3">
          <AppInput v-model="form.first_name" label="Prénom" required placeholder="Jean" />
          <AppInput v-model="form.last_name" label="Nom" required placeholder="Dupont" />
        </div>

        <AppInput
          v-model="form.email"
          label="Adresse e-mail"
          type="email"
          required
          placeholder="vous@sghl.com"
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
              class="w-full px-4 py-2.5 pr-11 text-sm rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400 bg-white transition"
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
          S'inscrire et recevoir le code
        </AppButton>
      </form>
    </template>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- Step 3 : OTP verification                                            -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <template v-else>
      <div class="mb-8">
        <!-- Email icon -->
        <div class="w-16 h-16 rounded-2xl bg-blue-100 flex items-center justify-center mb-5">
          <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-1">Vérifiez votre email</h2>
        <p class="text-gray-500 text-sm">
          Un code à 6 chiffres a été envoyé à
          <span class="font-semibold text-gray-700">{{ registeredEmail }}</span>
        </p>
      </div>

      <!-- Dev mode: show OTP directly -->
      <div
        v-if="devOtpCode"
        class="mb-5 p-4 rounded-2xl bg-yellow-50 border-2 border-yellow-300"
      >
        <div class="flex items-center gap-2 mb-2">
          <svg class="w-5 h-5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p class="text-xs font-bold text-yellow-700 uppercase tracking-wide">Mode développement — Code OTP</p>
        </div>
        <p class="text-3xl font-bold text-yellow-800 tracking-[0.3em] text-center py-1">{{ devOtpCode }}</p>
        <p class="text-xs text-yellow-600 text-center mt-1">Email non envoyé (SMTP non configuré)</p>
        <button
          type="button"
          class="mt-2 w-full text-xs text-yellow-700 hover:text-yellow-900 font-medium underline"
          @click="otpCode = devOtpCode"
        >Copier dans le champ ci-dessous</button>
      </div>

      <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

      <!-- OTP input -->
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-700 mb-2">Code de vérification</label>
        <input
          v-model="otpCode"
          type="text"
          inputmode="numeric"
          maxlength="6"
          placeholder="000000"
          class="w-full text-center text-3xl font-bold tracking-[0.5em] px-4 py-4 rounded-2xl border-2 border-gray-200 focus:outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-100 bg-white transition placeholder:tracking-normal placeholder:text-3xl placeholder:font-normal placeholder:text-gray-300"
          @input="otpCode = otpCode.replace(/\D/g, '').slice(0, 6)"
        />
      </div>

      <AppButton
        :loading="loading"
        :disabled="otpCode.length !== 6"
        full
        size="lg"
        class="!py-3 !rounded-xl mb-4"
        @click="handleVerify"
      >
        Vérifier et accéder à mon espace
      </AppButton>

      <!-- Resend -->
      <div class="text-center">
        <p class="text-sm text-gray-500 mb-2">Vous n'avez pas reçu le code ?</p>
        <button
          type="button"
          :disabled="resendCooldown > 0"
          :class="[
            'text-sm font-medium transition',
            resendCooldown > 0
              ? 'text-gray-400 cursor-not-allowed'
              : 'text-blue-600 hover:text-blue-800 hover:underline',
          ]"
          @click="resendOTP"
        >
          <span v-if="resendCooldown > 0">Renvoyer dans {{ formatCooldown(resendCooldown) }}</span>
          <span v-else>Renvoyer le code</span>
        </button>
      </div>

      <!-- Security note -->
      <div class="mt-6 p-3 rounded-xl bg-amber-50 border border-amber-100 flex items-start gap-2">
        <svg class="w-4 h-4 text-amber-500 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <p class="text-xs text-amber-700">Le code expire dans 10 minutes. Vérifiez aussi vos spams.</p>
      </div>
    </template>
  </AuthLayout>
</template>
