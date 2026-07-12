import api from './api'

export const hrService = {
  listStaff: (params) => api.get('/rh/personnel', { params }),
  createStaff: (data) => api.post('/rh/personnel', data),
  listShifts: (params) => api.get('/rh/gardes', { params }),
  createShift: (data) => api.post('/rh/gardes', data),
  confirmShift: (id) => api.patch(`/rh/gardes/${id}/confirmer`),
}
