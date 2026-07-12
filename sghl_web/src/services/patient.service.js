import api from './api'

export const patientService = {
  list: (params) => api.get('/patients', { params }),
  get: (id) => api.get(`/patients/${id}`),
  create: (data) => api.post('/patients', data),
  update: (id, data) => api.patch(`/patients/${id}`, data),
  archive: (id) => api.delete(`/patients/${id}/archive`),
  updateConsent: (id, data) => api.post(`/patients/${id}/consentement`, data),
  listDocuments: (id) => api.get(`/patients/${id}/documents`),
  uploadDocument: (id, formData) =>
    api.post(`/patients/${id}/documents`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),
}
