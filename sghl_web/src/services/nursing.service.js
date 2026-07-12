import api from './api'

export const nursingService = {
  // Care plans
  createCarePlan: (data) => api.post('/soins/plans', data),
  getCarePlan: (planId) => api.get(`/soins/plans/${planId}`),

  // Tasks
  completeTask: (taskId, data) => api.post(`/soins/taches/${taskId}/effectuer`, data),

  // Vital signs
  listVitalSigns: (hospId) => api.get(`/soins/hospitalisations/${hospId}/constantes`),
  recordVitalSigns: (hospId, data) => api.post(`/soins/hospitalisations/${hospId}/constantes`, data),

  // Nursing notes
  listNotes: (hospId) => api.get(`/soins/hospitalisations/${hospId}/notes`),
  addNote: (hospId, data) => api.post(`/soins/hospitalisations/${hospId}/notes`, data),
}
