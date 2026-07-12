import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { messagingService } from '@/services/messaging.service'
import { useAuthStore } from '@/stores/auth.store'

export function useConversations() {
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['conversations'],
    queryFn: async () => (await messagingService.listConversations()).data,
  })
  return { conversations: data, loading: isLoading, refetch }
}

export function useCreateConversation() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => messagingService.createConversation(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['conversations'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useMessages(convId) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: computed(() => ['messages', convId?.value ?? convId]),
    queryFn: async () => (await messagingService.listMessages(convId?.value ?? convId)).data,
    enabled: computed(() => !!(convId?.value ?? convId)),
    refetchInterval: 5000,
  })
  return { messages: data, loading: isLoading, refetch }
}

export function useChatSocket(convId) {
  const auth = useAuthStore()
  const socket = ref(null)
  const connected = ref(false)
  const incomingMessage = ref(null)

  function connect() {
    if (!convId || socket.value) return
    const wsBase = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1')
      .replace(/^http/, 'ws')
      .replace(/\/api(\/v\d+)?$/, '')
    const token = auth.accessToken
    socket.value = new WebSocket(`${wsBase}/ws/chat/${convId}/?token=${token}`)

    socket.value.onopen = () => { connected.value = true }
    socket.value.onclose = () => { connected.value = false; socket.value = null }
    socket.value.onerror = () => { connected.value = false }
    socket.value.onmessage = (e) => {
      try { incomingMessage.value = JSON.parse(e.data) } catch {}
    }
  }

  function disconnect() {
    socket.value?.close()
    socket.value = null
    connected.value = false
  }

  function sendMessage(content) {
    if (socket.value?.readyState === WebSocket.OPEN) {
      socket.value.send(JSON.stringify({ content }))
      return true
    }
    return false
  }

  return { connect, disconnect, sendMessage, connected, incomingMessage }
}
