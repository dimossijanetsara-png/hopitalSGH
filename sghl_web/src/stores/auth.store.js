import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/auth.service'

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref(localStorage.getItem('access_token') || null)
  const refreshToken = ref(localStorage.getItem('refresh_token') || null)
  const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
  const mfaPending = ref(false)
  const mfaUserId = ref(null)
  // Temporary storage for MFA flow — cleared after login or logout
  const _mfaCreds = ref(null)

  const isAuthenticated = computed(() => !!accessToken.value && !!user.value)
  const currentRole = computed(() => user.value?.role || null)
  const fullName = computed(() =>
    user.value ? `${user.value.first_name} ${user.value.last_name}` : '',
  )

  function setTokens(access, refresh) {
    accessToken.value = access
    refreshToken.value = refresh
    localStorage.setItem('access_token', access)
    localStorage.setItem('refresh_token', refresh)
  }

  function setUser(userData) {
    user.value = userData
    localStorage.setItem('user', JSON.stringify(userData))
  }

  async function login(credentials) {
    const { data } = await authService.login(credentials)
    if (data.mfa_required) {
      mfaPending.value = true
      mfaUserId.value = data.user_id
      // Keep credentials so loginWithMFA can re-send email+password+mfa_token
      _mfaCreds.value = { email: credentials.email, password: credentials.password }
      return { mfaRequired: true }
    }
    setTokens(data.access, data.refresh)
    await fetchMe()
    return { mfaRequired: false }
  }

  async function loginWithMFA(mfaToken) {
    if (!_mfaCreds.value) throw new Error('Session MFA expirée. Veuillez vous reconnecter.')
    const { data } = await authService.login({
      email: _mfaCreds.value.email,
      password: _mfaCreds.value.password,
      mfa_token: mfaToken,
    })
    setTokens(data.access, data.refresh)
    mfaPending.value = false
    mfaUserId.value = null
    _mfaCreds.value = null
    await fetchMe()
  }

  async function fetchMe() {
    const { data } = await authService.getMe()
    setUser(data)
  }

  async function refresh() {
    const { data } = await authService.refresh(refreshToken.value)
    accessToken.value = data.access
    localStorage.setItem('access_token', data.access)
  }

  function logout() {
    if (refreshToken.value) {
      authService.logout(refreshToken.value).catch(() => {})
    }
    accessToken.value = null
    refreshToken.value = null
    user.value = null
    mfaPending.value = false
    mfaUserId.value = null
    _mfaCreds.value = null
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user')
  }

  return {
    accessToken,
    refreshToken,
    user,
    mfaPending,
    isAuthenticated,
    currentRole,
    fullName,
    login,
    loginWithMFA,
    fetchMe,
    refresh,
    logout,
    setUser,
  }
})
