import api from './api'

export const pharmacyService = {
  // Medications
  listMedications: (params) => api.get('/pharmacie/medicaments', { params }),
  getMedication: (id) => api.get(`/pharmacie/medicaments/${id}`),

  // Batches
  listBatches: (params) => api.get('/pharmacie/lots', { params }),
  receiveBatch: (data) => api.post('/pharmacie/lots', data),

  // Dispensations
  createDispensation: (data) => api.post('/pharmacie/dispensations', data),

  // Stock movements
  listMovements: (params) => api.get('/pharmacie/mouvements', { params }),

  // Alerts
  getLowStockAlerts: () => api.get('/pharmacie/alertes/rupture'),
}
