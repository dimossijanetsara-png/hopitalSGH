import api from './api'

export const messagingService = {
  listConversations: () => api.get('/messagerie/conversations'),
  createConversation: (data) => api.post('/messagerie/conversations', data),
  listMessages: (convId) => api.get(`/messagerie/conversations/${convId}/messages`),
}
