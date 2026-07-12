import api from './api'

export const authService = {
  setupStatus: () => api.get('/auth/setup'),
  setupFirstAdmin: (data) => api.post('/auth/setup', data),
  login: (credentials) => api.post('/auth/login', credentials),
  refresh: (refreshToken) => api.post('/auth/refresh', { refresh: refreshToken }),
  logout: (refreshToken) => api.post('/auth/logout', { refresh: refreshToken }),
  register: (data) => api.post('/auth/register', data),
  registerPublic: (data) => api.post('/auth/register/public', data),
  verifyOTP: (data) => api.post('/auth/verify-otp', data),
  resendOTP: (data) => api.post('/auth/resend-otp', data),
  listUsers: (params) => api.get('/auth/users', { params }),
  toggleUser: (id) => api.patch(`/auth/users/${id}`),
  getMe: () => api.get('/auth/me'),
  updateMe: (data) => api.patch('/auth/me', data),
  changePassword: (data) => api.post('/auth/change-password', data),
  setupMFA: () => api.post('/auth/mfa/setup'),
  verifyMFA: (data) => api.post('/auth/mfa/verify', data),
  disableMFA: (data) => api.delete('/auth/mfa/disable', { data }),
}
