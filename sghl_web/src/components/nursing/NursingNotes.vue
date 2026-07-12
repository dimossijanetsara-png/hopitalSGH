<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { NOTE_CATEGORIES, NOTE_CATEGORY_COLORS } from '@/models/nursing.model'

const props = defineProps({
  notes: { type: Array, default: () => [] },
  loading: Boolean,
  addLoading: Boolean,
  addError: String,
})

const emit = defineEmits(['add'])

const showForm = ref(false)
const form = ref({ content: '', category: '' })

function handleSubmit() {
  if (!form.value.content.trim()) return
  emit('add', { ...form.value })
  form.value = { content: '', category: '' }
  showForm.value = false
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', {
    day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
  })
}

function categoryLabel(v) {
  return NOTE_CATEGORIES.find((c) => c.value === v)?.label || 'Général'
}
</script>

<template>
  <div class="space-y-4">
    <!-- Add note button -->
    <div class="flex justify-end">
      <AppButton size="sm" @click="showForm = !showForm">
        {{ showForm ? 'Annuler' : '+ Ajouter une note' }}
      </AppButton>
    </div>

    <!-- Add form -->
    <div v-if="showForm" class="bg-blue-50 rounded-xl border border-blue-200 p-4 space-y-3">
      <AppAlert v-if="addError" type="error" :message="addError" />
      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">Catégorie</label>
        <select
          v-model="form.category"
          class="w-full sm:w-48 px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        >
          <option v-for="c in NOTE_CATEGORIES" :key="c.value" :value="c.value">{{ c.label }}</option>
        </select>
      </div>
      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">
          Contenu <span class="text-red-500">*</span>
        </label>
        <textarea
          v-model="form.content"
          rows="4"
          placeholder="Saisir la note infirmière…"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
        />
      </div>
      <div class="flex justify-end">
        <AppButton :loading="addLoading" :disabled="!form.content.trim()" @click="handleSubmit">
          Enregistrer
        </AppButton>
      </div>
    </div>

    <!-- Notes list -->
    <div v-if="loading" class="flex justify-center py-8"><AppSpinner /></div>
    <div v-else-if="!notes.length" class="text-center py-8 text-gray-400 text-sm">
      Aucune note infirmière
    </div>
    <div v-else class="space-y-3">
      <div
        v-for="note in notes"
        :key="note.id"
        class="bg-white rounded-xl border border-gray-200 p-4"
      >
        <div class="flex items-center justify-between mb-2">
          <AppBadge :color-class="NOTE_CATEGORY_COLORS[note.category] || 'bg-gray-100 text-gray-600'">
            {{ categoryLabel(note.category) }}
          </AppBadge>
          <span class="text-xs text-gray-400">{{ formatDate(note.created_at) }}</span>
        </div>
        <p class="text-sm text-gray-700 whitespace-pre-wrap leading-relaxed">{{ note.content }}</p>
      </div>
    </div>
  </div>
</template>
