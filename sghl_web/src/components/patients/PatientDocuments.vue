<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppModal from '@/components/ui/AppModal.vue'
import { DOC_TYPES, DOC_TYPE_LABELS, DOC_TYPE_COLORS } from '@/models/patient.model'
import { usePatientDocuments, useUploadDocument } from '@/controllers/usePatients'
import { formatDate } from '@/models/patient.model'

const props = defineProps({ patientId: { type: String, required: true } })

const { documents, loading } = usePatientDocuments(props.patientId)
const { upload, loading: uploading, error: uploadError, success: uploadSuccess } = useUploadDocument(props.patientId)

const showModal = ref(false)
const docForm = ref({ doc_type: 'IDENTITY', title: '', description: '' })
const file = ref(null)

function onFileChange(e) {
  file.value = e.target.files[0] || null
}

function handleUpload() {
  if (!file.value) return
  const fd = new FormData()
  fd.append('doc_type', docForm.value.doc_type)
  fd.append('title', docForm.value.title)
  fd.append('description', docForm.value.description)
  fd.append('file', file.value)
  upload(fd)
  showModal.value = false
  docForm.value = { doc_type: 'IDENTITY', title: '', description: '' }
  file.value = null
}

function fileSize(bytes) {
  if (!bytes) return ''
  if (bytes < 1024) return bytes + ' o'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' Ko'
  return (bytes / 1024 / 1024).toFixed(1) + ' Mo'
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-sm font-semibold text-gray-700">Documents ({{ documents?.length ?? 0 }})</h3>
      <AppButton size="sm" @click="showModal = true">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Ajouter
      </AppButton>
    </div>

    <AppAlert v-if="uploadError" type="error" :message="uploadError" class="mb-3" />
    <AppAlert v-if="uploadSuccess" type="success" message="Document uploadé avec succès." class="mb-3" />

    <div v-if="loading" class="space-y-2">
      <div v-for="i in 3" :key="i" class="h-14 bg-gray-100 rounded-lg animate-pulse" />
    </div>

    <div v-else-if="!documents?.length" class="text-center py-10 text-gray-400 text-sm border border-dashed border-gray-200 rounded-lg">
      Aucun document
    </div>

    <div v-else class="space-y-2">
      <a
        v-for="doc in documents"
        :key="doc.id"
        :href="doc.file"
        target="_blank"
        class="flex items-center gap-4 p-3 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-colors group"
      >
        <div class="w-9 h-9 bg-gray-100 rounded-lg flex items-center justify-center group-hover:bg-blue-100">
          <svg class="w-5 h-5 text-gray-500 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-800 truncate">{{ doc.title }}</p>
          <div class="flex items-center gap-2 mt-0.5">
            <AppBadge :label="DOC_TYPE_LABELS[doc.doc_type]" :color="DOC_TYPE_COLORS[doc.doc_type]" />
            <span class="text-xs text-gray-400">{{ formatDate(doc.created_at) }}</span>
            <span v-if="doc.file_size" class="text-xs text-gray-400">· {{ fileSize(doc.file_size) }}</span>
          </div>
        </div>
        <svg class="w-4 h-4 text-gray-400 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
        </svg>
      </a>
    </div>

    <!-- Upload Modal -->
    <AppModal :open="showModal" title="Ajouter un document" @close="showModal = false">
      <div class="space-y-4">
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Type de document</label>
          <select v-model="docForm.doc_type"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300">
            <option v-for="dt in DOC_TYPES" :key="dt.value" :value="dt.value">{{ dt.label }}</option>
          </select>
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Titre <span class="text-red-500">*</span></label>
          <input v-model="docForm.title" type="text" required
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300" />
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Description</label>
          <textarea v-model="docForm.description" rows="2"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Fichier <span class="text-red-500">*</span></label>
          <input type="file" accept=".pdf,.jpg,.jpeg,.png" @change="onFileChange"
            class="w-full text-sm text-gray-600 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:bg-blue-50 file:text-blue-700 file:text-xs file:font-medium hover:file:bg-blue-100" />
          <p class="text-xs text-gray-400">PDF, JPG, PNG · Max 10 Mo</p>
        </div>
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showModal = false">Annuler</AppButton>
        <AppButton :loading="uploading" :disabled="!file" @click="handleUpload">Uploader</AppButton>
      </template>
    </AppModal>
  </div>
</template>
