import api from './api'

export const hospitalisationService = {
  // Infrastructure
  listBuildings: (params) => api.get('/hospitalisation/batiments', { params }),
  createBuilding: (data) => api.post('/hospitalisation/batiments', data),

  listDepartments: (params) => api.get('/hospitalisation/services', { params }),
  createDepartment: (data) => api.post('/hospitalisation/services', data),

  listRooms: (params) => api.get('/hospitalisation/chambres', { params }),
  createRoom: (data) => api.post('/hospitalisation/chambres', data),

  listBeds: (params) => api.get('/hospitalisation/lits', { params }),
  createBed: (data) => api.post('/hospitalisation/lits', data),
  getAvailableBeds: (params) => api.get('/hospitalisation/lits/disponibles', { params }),

  // Admissions
  listAdmissions: (params) => api.get('/hospitalisation/admissions', { params }),
  getAdmission: (id) => api.get(`/hospitalisation/admissions/${id}`),
  createAdmission: (data) => api.post('/hospitalisation/admissions', data),
  discharge: (id, data) => api.post(`/hospitalisation/admissions/${id}/sortie`, data),
  transfer: (id, data) => api.post(`/hospitalisation/admissions/${id}/transfert`, data),
}
