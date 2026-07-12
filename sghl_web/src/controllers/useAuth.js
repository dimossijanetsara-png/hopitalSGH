import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth.store'
import { authService } from '@/services/auth.service'
import { DASHBOARD_ROUTES_BY_ROLE } from '@/models/auth.model'

export function useLogin() {
  const auth = useAuthStore()
  const router = useRouter()
  const loading = ref(false)
  const error = ref(null)

  async function submit(credentials) {
    loading.value = true
    error.value = null
    try {
      const result = await auth.login(credentials)
      if (result.mfaRequired) {
        router.push({ name: 'mfa' })
      } else {
        const route = DASHBOARD_ROUTES_BY_ROLE[auth.currentRole] || '/dashboard'
        router.push(route)
      }
    } catch (err) {
      error.value = err.response?.data?.detail || 'Identifiants incorrects.'
    } finally {
      loading.value = false
    }
  }

  return { loading, error, submit }
}

export function useMFA() {
  const auth = useAuthStore()
  const router = useRouter()
  const loading = ref(false)
  const error = ref(null)

  async function submit(token) {
    loading.value = true
    error.value = null
    try {
      await auth.loginWithMFA(token)
      const route = DASHBOARD_ROUTES_BY_ROLE[auth.currentRole] || '/dashboard'
      router.push(route)
    } catch (err) {
      error.value = err.response?.data?.detail || 'Code MFA invalide.'
    } finally {
      loading.value = false
    }
  }

  return { loading, error, submit }
}

export function useProfile() {
  const auth = useAuthStore()
  const loading = ref(false)
  const error = ref(null)
  const success = ref(false)

  async function updateProfile(data) {
    loading.value = true
    error.value = null
    success.value = false
    try {
      const response = await authService.updateMe(data)
      auth.setUser(response.data)
      success.value = true
    } catch (err) {
      error.value = err.response?.data?.detail || 'Erreur lors de la mise à jour.'
    } finally {
      loading.value = false
    }
  }

  return { loading, error, success, updateProfile }
}

export function useChangePassword() {
  const loading = ref(false)
  const error = ref(null)
  const success = ref(false)

  async function submit(data) {
    loading.value = true
    error.value = null
    success.value = false
    try {
      await authService.changePassword(data)
      success.value = true
    } catch (err) {
      error.value = err.response?.data?.detail || 'Erreur lors du changement de mot de passe.'
    } finally {
      loading.value = false
    }
  }

  return { loading, error, success, submit }
}

export function useSetupMFA() {
  const auth = useAuthStore()
  const loading = ref(false)
  const error = ref(null)
  const mfaData = ref(null)
  const activated = ref(false)
  const disableToken = ref('')
  const showDisableInput = ref(false)
  const disableSuccess = ref(false)

  async function setup() {
    loading.value = true
    error.value = null
    try {
      const { data } = await authService.setupMFA()
      mfaData.value = data
    } catch (err) {
      error.value = err.response?.data?.detail || 'Erreur lors de la configuration MFA.'
    } finally {
      loading.value = false
    }
  }

  async function verify(token) {
    loading.value = true
    error.value = null
    try {
      await authService.verifyMFA({ token })
      activated.value = true
      // Sync store so mfa_enabled reflects the new state
      await auth.fetchMe()
    } catch (err) {
      error.value = err.response?.data?.detail || 'Code invalide.'
    } finally {
      loading.value = false
    }
  }

  async function disable(token) {
    loading.value = true
    error.value = null
    try {
      await authService.disableMFA({ token })
      disableSuccess.value = true
      showDisableInput.value = false
      disableToken.value = ''
      await auth.fetchMe()
    } catch (err) {
      error.value = err.response?.data?.detail || 'Erreur lors de la désactivation.'
    } finally {
      loading.value = false
    }
  }

  return { loading, error, mfaData, activated, disableToken, showDisableInput, disableSuccess, setup, verify, disable }
}
