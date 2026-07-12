import api from './api'

export const appointmentsService = {
  listAppointments: (params) => api.get('/rendez-vous', { params }),
  createAppointment: (data) => api.post('/rendez-vous', data),
  updateAppointment: (id, data) => api.patch(`/rendez-vous/${id}`, data),
  getDoctorAvailability: (doctorId) => api.get(`/rendez-vous/disponibilites/${doctorId}`),
  createAvailability: (data) => api.post('/rendez-vous/disponibilites', data),
}
