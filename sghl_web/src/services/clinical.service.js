import api from './api'

export const clinicalService = {
  // Consultations
  listConsultations: (params) => api.get('/clinique/consultations', { params }),
  getConsultation: (id) => api.get(`/clinique/consultations/${id}`),
  createConsultation: (data) => api.post('/clinique/consultations', data),
  updateConsultation: (id, data) => api.patch(`/clinique/consultations/${id}`, data),

  // Diagnostics
  addDiagnosis: (consultationId, data) =>
    api.post(`/clinique/consultations/${consultationId}/diagnostics`, data),

  // Prescriptions
  createPrescription: (consultationId, data) =>
    api.post(`/clinique/consultations/${consultationId}/prescriptions`, data),
  validatePrescription: (prescriptionId) =>
    api.post(`/clinique/prescriptions/${prescriptionId}/valider`),
}
