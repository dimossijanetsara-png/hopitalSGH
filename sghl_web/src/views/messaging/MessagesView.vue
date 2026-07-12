<script setup>
import { ref, computed, watch, nextTick, onUnmounted } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { useConversations, useCreateConversation, useMessages, useChatSocket } from '@/controllers/useMessaging'
import { useAuthStore } from '@/stores/auth.store'

const auth = useAuthStore()
const selectedConvId = ref(null)
const messageInput = ref('')
const messagesEl = ref(null)

// Conversations
const { conversations, loading: convsLoading, refetch: refetchConvs } = useConversations()
const convList = computed(() => conversations.value?.results || conversations.value || [])

// Messages (REST poll every 5s)
const { messages, loading: msgsLoading } = useMessages(selectedConvId)
const msgList = computed(() => {
  const list = messages.value?.results || messages.value || []
  return [...list].sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
})

// WebSocket
const { connect, disconnect, sendMessage, connected, incomingMessage } = useChatSocket(selectedConvId.value)

watch(selectedConvId, (id) => {
  disconnect()
  if (id) connect()
})

watch(incomingMessage, (msg) => {
  if (!msg) return
  // New WS message arrived — TanStack Query will pick it up on next poll
  // Scroll to bottom
  nextTick(() => scrollToBottom())
})

watch(msgList, () => nextTick(() => scrollToBottom()), { flush: 'post' })

onUnmounted(() => disconnect())

function scrollToBottom() {
  if (messagesEl.value) messagesEl.value.scrollTop = messagesEl.value.scrollHeight
}

function handleSend() {
  const content = messageInput.value.trim()
  if (!content) return
  const sent = sendMessage(content)
  if (!sent) {
    // WS not open — graceful degradation (read-only without WS)
  }
  messageInput.value = ''
}

function handleKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    handleSend()
  }
}

// Create conversation
const showCreate = ref(false)
const createForm = ref({ subject: '', participant_ids_raw: '' })
const { submit: createConv, loading: creating, error: createError } = useCreateConversation()

function handleCreate() {
  const ids = createForm.value.participant_ids_raw.split(',').map((s) => s.trim()).filter(Boolean)
  createConv(
    { subject: createForm.value.subject, participant_ids: ids },
    {
      onSuccess: ({ data }) => {
        showCreate.value = false
        createForm.value = { subject: '', participant_ids_raw: '' }
        selectedConvId.value = data.id
      },
    },
  )
}

function formatTime(d) {
  if (!d) return ''
  const date = new Date(d)
  const now = new Date()
  if (date.toDateString() === now.toDateString()) {
    return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  }
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
}

function isMine(msg) {
  return msg.sender_id === auth.user?.id
}

function convLabel(conv) {
  return conv.subject || `Conversation ${conv.id?.slice(0, 6)}`
}
</script>

<template>
  <DashboardLayout>
    <div class="flex h-[calc(100vh-8rem)] gap-0 bg-white rounded-xl border border-gray-200 overflow-hidden">

      <!-- ─── Sidebar: conversation list ─── -->
      <div class="w-64 sm:w-72 shrink-0 flex flex-col border-r border-gray-200">
        <div class="p-3 border-b border-gray-100 flex items-center justify-between">
          <h2 class="font-semibold text-gray-800 text-sm">Messages</h2>
          <button @click="showCreate = true"
            class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
          </button>
        </div>

        <div class="flex-1 overflow-y-auto">
          <div v-if="convsLoading" class="flex justify-center py-8"><AppSpinner /></div>
          <div v-else-if="!convList.length" class="p-4 text-center text-gray-400 text-sm">
            Aucune conversation
          </div>
          <button
            v-else
            v-for="conv in convList"
            :key="conv.id"
            :class="[
              'w-full text-left px-4 py-3 border-b border-gray-50 transition-colors',
              selectedConvId === conv.id ? 'bg-blue-50' : 'hover:bg-gray-50',
            ]"
            @click="selectedConvId = conv.id"
          >
            <div class="flex items-start justify-between gap-2">
              <p :class="['text-sm font-medium truncate', selectedConvId === conv.id ? 'text-blue-700' : 'text-gray-800']">
                {{ convLabel(conv) }}
              </p>
              <span class="text-xs text-gray-400 shrink-0">{{ formatTime(conv.created_at) }}</span>
            </div>
          </button>
        </div>
      </div>

      <!-- ─── Main: message thread ─── -->
      <div class="flex-1 flex flex-col min-w-0">
        <!-- Empty state -->
        <div v-if="!selectedConvId" class="flex-1 flex flex-col items-center justify-center text-gray-400">
          <svg class="w-16 h-16 mb-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
          <p class="text-sm">Sélectionnez une conversation</p>
          <button class="mt-3 text-sm text-blue-600 hover:underline" @click="showCreate = true">
            Ou démarrez-en une nouvelle
          </button>
        </div>

        <template v-else>
          <!-- Header -->
          <div class="px-4 py-3 border-b border-gray-200 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <p class="font-semibold text-gray-800 text-sm">
                {{ convLabel(convList.find(c => c.id === selectedConvId) || {}) }}
              </p>
              <span v-if="connected" class="w-2 h-2 rounded-full bg-green-500 inline-block" title="Connecté (temps réel)" />
            </div>
          </div>

          <!-- Messages -->
          <div ref="messagesEl" class="flex-1 overflow-y-auto p-4 space-y-3">
            <div v-if="msgsLoading && !msgList.length" class="flex justify-center py-8"><AppSpinner /></div>
            <div v-else-if="!msgList.length" class="text-center text-gray-400 text-sm py-8">
              Aucun message — soyez le premier à écrire !
            </div>

            <div v-for="msg in msgList" :key="msg.id"
              :class="['flex', isMine(msg) ? 'justify-end' : 'justify-start']">
              <div :class="[
                'max-w-[70%] px-4 py-2.5 rounded-2xl text-sm',
                isMine(msg)
                  ? 'bg-blue-600 text-white rounded-br-sm'
                  : 'bg-gray-100 text-gray-800 rounded-bl-sm',
              ]">
                <p class="whitespace-pre-wrap break-words">{{ msg.content }}</p>
                <p :class="['text-xs mt-1', isMine(msg) ? 'text-blue-200 text-right' : 'text-gray-400']">
                  {{ formatTime(msg.created_at) }}
                  <span v-if="!isMine(msg) && msg.is_read" class="ml-1 opacity-70">✓</span>
                </p>
              </div>
            </div>
          </div>

          <!-- Input -->
          <div class="border-t border-gray-200 p-3 flex gap-2">
            <textarea
              v-model="messageInput"
              rows="1"
              placeholder="Écrire un message…"
              class="flex-1 px-3 py-2 text-sm rounded-xl border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
              style="max-height: 120px; overflow-y: auto"
              @keydown="handleKeydown"
            />
            <button
              :disabled="!messageInput.trim() || !connected"
              :class="[
                'px-4 py-2 rounded-xl text-sm font-medium transition-colors',
                messageInput.trim() && connected
                  ? 'bg-blue-600 text-white hover:bg-blue-700'
                  : 'bg-gray-100 text-gray-400 cursor-not-allowed',
              ]"
              @click="handleSend"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>

          <p v-if="!connected && selectedConvId"
            class="text-xs text-center text-gray-400 pb-2">
            WebSocket non connecté — les messages seront rafraîchis toutes les 5s
          </p>
        </template>
      </div>
    </div>

    <!-- New conversation modal -->
    <AppModal :open="showCreate" title="Nouvelle conversation" size="sm" @close="showCreate = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Sujet</label>
          <input v-model="createForm.subject" type="text" placeholder="Objet de la conversation (optionnel)"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">
            Participants (UUIDs séparés par virgule) <span class="text-red-500">*</span>
          </label>
          <textarea v-model="createForm.participant_ids_raw" rows="3"
            placeholder="uuid1, uuid2, uuid3…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showCreate = false">Annuler</AppButton>
        <AppButton :loading="creating" :disabled="!createForm.participant_ids_raw.trim()" @click="handleCreate">
          Démarrer
        </AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
