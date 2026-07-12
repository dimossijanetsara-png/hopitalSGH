<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppInput from '@/components/ui/AppInput.vue'
import {
  TASK_FREQUENCIES, TASK_STATUSES, TASK_STATUS_COLORS,
  PLAN_STATUS_COLORS, PLAN_STATUSES,
} from '@/models/nursing.model'

const props = defineProps({
  hospId: { type: String, required: true },
  carePlan: { type: Object, default: null },
  loading: Boolean,
  createLoading: Boolean,
  createError: String,
  completeLoading: Boolean,
})

const emit = defineEmits(['create', 'completeTask'])

// Create plan form
const showCreateModal = ref(false)
const createForm = ref({ goals: '', notes: '', tasks: [] })

function addTask() {
  createForm.value.tasks.push({ title: '', description: '', frequency: 'DAILY', scheduled_time: '' })
}
function removeTask(i) {
  createForm.value.tasks.splice(i, 1)
}
function submitCreate() {
  emit('create', {
    ...createForm.value,
    tasks: createForm.value.tasks.filter((t) => t.title.trim()),
  })
}

// Complete task
const completingTaskId = ref(null)
const taskNotes = ref('')
function openComplete(taskId) {
  completingTaskId.value = taskId
  taskNotes.value = ''
}
function submitComplete() {
  emit('completeTask', { taskId: completingTaskId.value, notes: taskNotes.value })
  completingTaskId.value = null
}

function labelFreq(v) {
  return TASK_FREQUENCIES.find((f) => f.value === v)?.label || v
}
function labelStatus(v) {
  return TASK_STATUSES.find((s) => s.value === v)?.label || v
}
</script>

<template>
  <div>
    <!-- No plan -->
    <div v-if="loading" class="flex justify-center py-12"><AppSpinner /></div>
    <div v-else-if="!carePlan" class="text-center py-12">
      <svg class="w-12 h-12 mx-auto mb-3 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
      </svg>
      <p class="text-gray-500 mb-4">Aucun plan de soins pour cette hospitalisation</p>
      <AppButton @click="showCreateModal = true">Créer un plan de soins</AppButton>
    </div>

    <!-- Plan exists -->
    <div v-else class="space-y-4">
      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <AppBadge :color-class="PLAN_STATUS_COLORS[carePlan.status] || 'bg-gray-100 text-gray-600'">
            {{ PLAN_STATUSES.find((s) => s.value === carePlan.status)?.label || carePlan.status }}
          </AppBadge>
        </div>
        <span class="text-xs text-gray-400">
          {{ new Date(carePlan.created_at).toLocaleDateString('fr-FR') }}
        </span>
      </div>

      <!-- Goals & Notes -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div v-if="carePlan.goals" class="bg-blue-50 rounded-lg p-3">
          <p class="text-xs font-semibold text-blue-600 mb-1">Objectifs</p>
          <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ carePlan.goals }}</p>
        </div>
        <div v-if="carePlan.notes" class="bg-gray-50 rounded-lg p-3">
          <p class="text-xs font-semibold text-gray-500 mb-1">Notes</p>
          <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ carePlan.notes }}</p>
        </div>
      </div>

      <!-- Tasks -->
      <div>
        <h3 class="text-sm font-semibold text-gray-700 mb-2">
          Tâches ({{ carePlan.tasks?.length || 0 }})
        </h3>
        <div v-if="!carePlan.tasks?.length" class="text-sm text-gray-400">Aucune tâche</div>
        <div v-else class="space-y-2">
          <div
            v-for="task in carePlan.tasks"
            :key="task.id"
            class="flex items-start justify-between gap-3 bg-white rounded-lg border border-gray-200 p-3"
          >
            <div class="min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <p class="text-sm font-medium text-gray-800">{{ task.title }}</p>
                <AppBadge :color-class="TASK_STATUS_COLORS[task.status] || 'bg-gray-100 text-gray-500'">
                  {{ labelStatus(task.status) }}
                </AppBadge>
                <span class="text-xs text-gray-400">{{ labelFreq(task.frequency) }}</span>
              </div>
              <p v-if="task.description" class="text-xs text-gray-500 mt-0.5">{{ task.description }}</p>
              <p v-if="task.scheduled_time" class="text-xs text-gray-400 mt-0.5">
                Heure : {{ task.scheduled_time }}
              </p>
              <p v-if="task.notes && task.status === 'DONE'" class="text-xs text-green-600 mt-0.5 italic">
                Note : {{ task.notes }}
              </p>
            </div>
            <AppButton
              v-if="task.status === 'PENDING' && carePlan.status === 'ACTIVE'"
              size="sm"
              variant="success"
              :loading="completeLoading"
              @click="openComplete(task.id)"
            >
              Effectuer
            </AppButton>
          </div>
        </div>
      </div>
    </div>

    <!-- Create plan modal -->
    <AppModal :open="showCreateModal" title="Nouveau plan de soins" size="lg" @close="showCreateModal = false">
      <div class="space-y-4">
        <AppAlert v-if="createError" type="error" :message="createError" />

        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Objectifs</label>
          <textarea
            v-model="createForm.goals"
            rows="2"
            placeholder="Objectifs thérapeutiques…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
          />
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Notes</label>
          <textarea
            v-model="createForm.notes"
            rows="2"
            placeholder="Informations complémentaires…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
          />
        </div>

        <!-- Tasks -->
        <div>
          <div class="flex items-center justify-between mb-2">
            <label class="text-sm font-medium text-gray-700">Tâches</label>
            <AppButton size="sm" variant="ghost" @click="addTask">+ Ajouter</AppButton>
          </div>
          <div v-if="!createForm.tasks.length" class="text-xs text-gray-400">Aucune tâche — optionnel</div>
          <div v-else class="space-y-3">
            <div
              v-for="(task, i) in createForm.tasks"
              :key="i"
              class="bg-gray-50 rounded-lg p-3 space-y-2"
            >
              <div class="grid grid-cols-2 gap-2">
                <div>
                  <label class="text-xs text-gray-500">Titre *</label>
                  <input
                    v-model="task.title"
                    type="text"
                    placeholder="Nom de la tâche"
                    class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
                  />
                </div>
                <div>
                  <label class="text-xs text-gray-500">Fréquence</label>
                  <select
                    v-model="task.frequency"
                    class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
                  >
                    <option v-for="f in TASK_FREQUENCIES" :key="f.value" :value="f.value">
                      {{ f.label }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="grid grid-cols-2 gap-2">
                <div>
                  <label class="text-xs text-gray-500">Description</label>
                  <input
                    v-model="task.description"
                    type="text"
                    placeholder="Optionnel"
                    class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
                  />
                </div>
                <div>
                  <label class="text-xs text-gray-500">Heure prévue</label>
                  <input
                    v-model="task.scheduled_time"
                    type="time"
                    class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
                  />
                </div>
              </div>
              <div class="flex justify-end">
                <button @click="removeTask(i)" class="text-xs text-red-500 hover:text-red-700">Supprimer</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <AppButton variant="secondary" @click="showCreateModal = false">Annuler</AppButton>
        <AppButton :loading="createLoading" @click="submitCreate">Créer le plan</AppButton>
      </template>
    </AppModal>

    <!-- Complete task modal -->
    <AppModal
      :open="!!completingTaskId"
      title="Marquer la tâche comme effectuée"
      size="sm"
      @close="completingTaskId = null"
    >
      <div class="space-y-3">
        <label class="text-sm font-medium text-gray-700 block">Notes (optionnel)</label>
        <textarea
          v-model="taskNotes"
          rows="3"
          placeholder="Observations lors de l'exécution…"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
        />
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="completingTaskId = null">Annuler</AppButton>
        <AppButton variant="success" :loading="completeLoading" @click="submitComplete">Confirmer</AppButton>
      </template>
    </AppModal>
  </div>
</template>
