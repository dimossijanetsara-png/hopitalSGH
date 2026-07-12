import api from './api'

export const dashboardService = {
  getKpis: () => api.get('/dashboard/kpis'),
  getHospitalisationStats: () => api.get('/dashboard/statistiques/hospitalisations'),
  getRevenueStats: () => api.get('/dashboard/statistiques/revenus'),
}
