import api from './api'

export const billingService = {
  listInvoices: (params) => api.get('/facturation/factures', { params }),
  getInvoice: (id) => api.get(`/facturation/factures/${id}`),
  createInvoice: (data) => api.post('/facturation/factures', data),
  issueInvoice: (id) => api.post(`/facturation/factures/${id}/emettre`),
  listPayments: (id) => api.get(`/facturation/factures/${id}/paiements`),
  addPayment: (id, data) => api.post(`/facturation/factures/${id}/paiements`, data),
}
