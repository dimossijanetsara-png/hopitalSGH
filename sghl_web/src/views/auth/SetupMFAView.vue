<script setup>
import { ref, onMounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useSetupMFA } from '@/controllers/useAuth'
import { useAuthStore } from '@/stores/auth.store'

const auth = useAuthStore()
const { loading, error, mfaData, activated, disableToken, showDisableInput, disableSuccess, setup, verify, disable } = useSetupMFA()
const token = ref('')

onMounted(() => {
  if (!auth.user?.mfa_enabled) {
    setup()
  }
})
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
        <h1 class="text-2xl font-bold text-gray-900">Authentification à deux facteurs</h1>
      </div>

      <!-- MFA déjà activée -->
      <div v-if="auth.user?.mfa_enabled && !activated" class="bg-white rounded-xl border border-gray-200 p-6">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
          </div>
          <div>
            <p class="font-semibold text-gray-900">MFA activée</p>
            <p class="text-sm text-gray-500">Votre compte est protégé par l'authentification à deux facteurs.</p>
          </div>
        </div>

        <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

        <!-- Désactivé avec succès -->
        <div v-if="disableSuccess" class="flex items-center gap-2 text-green-700 bg-green-50 rounded-lg p-3 text-sm mb-4">
          <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          MFA désactivée. Rechargez la page pour voir le changement.
        </div>

        <!-- Formulaire de désactivation -->
        <div v-if="showDisableInput" class="space-y-3 mb-4">
          <p class="text-sm text-gray-600">
            Entrez le code à 6 chiffres de votre application d'authentification pour confirmer la désactivation.
          </p>
          <AppInput
            v-model="disableToken"
            label="Code de vérification"
            type="text"
            inputmode="numeric"
            maxlength="6"
            placeholder="000000"
          />
          <div class="flex gap-2">
            <AppButton variant="secondary" @click="showDisableInput = false">Annuler</AppButton>
            <AppButton
              variant="danger"
              :loading="loading"
              :disabled="disableToken.length !== 6"
              @click="disable(disableToken)"
            >
              Confirmer la désactivation
            </AppButton>
          </div>
        </div>

        <AppButton v-else variant="danger" @click="showDisableInput = true">
          Désactiver la MFA
        </AppButton>
      </div>

      <!-- Setup MFA -->
      <div v-else-if="!activated" class="bg-white rounded-xl border border-gray-200 p-6">
        <AppAlert v-if="error" type="error" :message="error" class="mb-4" />

        <div v-if="loading && !mfaData" class="flex justify-center py-8">
          <div class="animate-spin w-8 h-8 border-4 border-blue-200 border-t-blue-700 rounded-full"></div>
        </div>

        <template v-if="mfaData">
          <p class="text-sm text-gray-600 mb-4">
            Scannez ce QR code avec votre application d'authentification
            (Google Authenticator, Authy…)
          </p>
          <div class="flex justify-center mb-4">
            <img
              :src="`data:image/png;base64,${mfaData.qr_image_base64}`"
              alt="QR Code MFA"
              class="w-48 h-48 rounded-lg border border-gray-200 p-2"
            />
          </div>
          <div class="bg-gray-50 rounded-lg p-3 mb-5 text-center">
            <p class="text-xs text-gray-500 mb-1">Ou saisissez ce code manuellement :</p>
            <code class="text-sm font-mono font-bold text-gray-800 tracking-widest">
              {{ mfaData.secret }}
            </code>
          </div>

          <AppInput
            v-model="token"
            label="Code de vérification (6 chiffres)"
            type="text"
            inputmode="numeric"
            maxlength="6"
            placeholder="000000"
            required
          />
          <AppButton
            class="mt-4"
            :loading="loading"
            full
            :disabled="token.length !== 6"
            @click="verify(token)"
          >
            Activer la MFA
          </AppButton>
        </template>
      </div>

      <!-- Succès -->
      <div v-else class="bg-white rounded-xl border border-green-200 p-6 text-center">
        <div class="w-14 h-14 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
          <svg class="w-7 h-7 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h3 class="text-lg font-semibold text-gray-900 mb-1">MFA activée avec succès !</h3>
        <p class="text-sm text-gray-500 mb-4">Votre compte est maintenant protégé.</p>
        <RouterLink to="/profil">
          <AppButton variant="secondary">Retour au profil</AppButton>
        </RouterLink>
      </div>
    </div>
  </DashboardLayout>
</template>
