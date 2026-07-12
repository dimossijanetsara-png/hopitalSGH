import api from './api'

export const laboratoryService = {
  // Catalog
  listTests: () => api.get('/laboratoire/analyses'),

  // Orders
  listOrders: (params) => api.get('/laboratoire/commandes', { params }),
  getOrder: (id) => api.get(`/laboratoire/commandes/${id}`),
  createOrder: (data) => api.post('/laboratoire/commandes', data),

  // Workflow
  sample: (id) => api.post(`/laboratoire/commandes/${id}/prelever`),
  assign: (id, data) => api.post(`/laboratoire/commandes/${id}/affecter`, data),
  enterResults: (id, data) => api.post(`/laboratoire/commandes/${id}/resultats`, data),
  validate: (id) => api.post(`/laboratoire/commandes/${id}/valider`),
  publish: (id) => api.post(`/laboratoire/commandes/${id}/publier`),
}
