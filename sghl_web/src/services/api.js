import axios from 'axios'
import { useAuthStore } from '@/stores/auth.store'
import router from '@/router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1',
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
})

api.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.accessToken) {
    config.headers.Authorization = `Bearer ${auth.accessToken}`
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      const auth = useAuthStore()
      try {
        await auth.refresh()
        originalRequest.headers.Authorization = `Bearer ${auth.accessToken}`
        return api(originalRequest)
      } catch {
        auth.logout()
        router.push({ name: 'login' })
      }
    }
    return Promise.reject(error)
  },
)

export default api
