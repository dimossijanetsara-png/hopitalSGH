<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import CarePlanPanel from '@/components/nursing/CarePlanPanel.vue'
import VitalSignsForm from '@/components/nursing/VitalSignsForm.vue'
import VitalSignsHistory from '@/components/nursing/VitalSignsHistory.vue'
import NursingNotes from '@/components/nursing/NursingNotes.vue'
import {
  useCarePlan, useCreateCarePlan, useCompleteTask,
  useVitalSigns, useRecordVitals,
  useNursingNotes, useAddNote,
} from '@/controllers/useNursing'

const route = useRoute()
const router = useRouter()

// Hospitalization ID (from query param or manual input)
const hospId = ref(route.query.hosp || '')
const searchInput = ref('')

function applySearch() {
  if (!searchInput.value.trim()) return
  hospId.value = searchInput.value.trim()
  router.replace({ query: { hosp: hospId.value } })
}

// Tabs
const activeTab = ref('vitals')
const TABS = [
  { key: 'vitals', label: 'Constantes vitales' },
  { key: 'plan', label: 'Plan de soins' },
  { key: 'notes', label: 'Notes infirmières' },
]

// ─── Vitals ───────────────────────────────────────────────────────────────────
const showVitalsForm = ref(false)
const { vitals, loading: vitalsLoading } = useVitalSigns(hospId)
const { submit: recordVitals, loading: recordingVitals, error: vitalsError } = useRecordVitals(hospId)

function onRecordVitals(data) {
  recordVitals(data, { onSuccess: () => { showVitalsForm.value = false } })
}

// ─── Care plan ────────────────────────────────────────────────────────────────
const carePlanId = ref(null)
const { carePlan, loading: planLoading } = useCarePlan(carePlanId)
const { submit: createPlan, loading: creatingPlan, error: createPlanError } = useCreateCarePlan(hospId.value)
const { complete: completeTask, loading: completingTask } = useCompleteTask(carePlanId)

watch(hospId, () => { carePlanId.value = null })

function onCreatePlan(data) {
  createPlan(data, {
    onSuccess: ({ data: plan }) => {
      carePlanId.value = plan.id
    },
  })
}

// ─── Notes ────────────────────────────────────────────────────────────────────
const { notes, loading: notesLoading } = useNursingNotes(hospId)
const { submit: addNote, loading: addingNote, error: addNoteError } = useAddNote(hospId.value)
</script>

<template>
  <DashboardLayout>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Soins Infirmiers</h1>
        <p class="text-sm text-gray-500 mt-0.5">Constantes, plan de soins et notes</p>
      </div>
    </div>

    <!-- Hospitalization selector -->
    <div class="bg-white rounded-xl border border-gray-200 p-4 mb-6">
      <label class="text-sm font-medium text-gray-700 block mb-2">Hospitalisation</label>
      <div class="flex gap-2">
        <input
          v-model="searchInput"
          type="text"
          placeholder="Saisir l'ID de l'hospitalisation (UUID)…"
          class="flex-1 px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
          @keydown.enter="applySearch"
        />
        <AppButton @click="applySearch">Charger</AppButton>
      </div>
      <p v-if="hospId" class="mt-2 text-xs text-blue-600 font-medium">
        Hospitalisation active : {{ hospId }}
      </p>
      <p v-else class="mt-2 text-xs text-gray-400">
        Vous pouvez accéder à cette vue depuis le détail d'une admission.
      </p>
    </div>

    <!-- Content (only when hospId is set) -->
    <template v-if="hospId">
      <!-- Tabs -->
      <div class="border-b border-gray-200 mb-6">
        <div class="flex gap-6">
          <button
            v-for="tab in TABS"
            :key="tab.key"
            :class="[
              'pb-3 text-sm font-medium transition-colors border-b-2 -mb-px',
              activeTab === tab.key
                ? 'border-blue-600 text-blue-600'
                : 'border-transparent text-gray-500 hover:text-gray-700',
            ]"
            @click="activeTab = tab.key"
          >
            {{ tab.label }}
          </button>
        </div>
      </div>

      <!-- Vitals tab -->
      <div v-if="activeTab === 'vitals'">
        <div class="flex justify-end mb-4">
          <AppButton size="sm" @click="showVitalsForm = !showVitalsForm">
            {{ showVitalsForm ? 'Annuler' : '+ Saisir des constantes' }}
          </AppButton>
        </div>

        <div v-if="showVitalsForm" class="bg-white rounded-xl border border-gray-200 p-5 mb-4">
          <h3 class="font-semibold text-gray-800 mb-4">Nouvelle prise de constantes</h3>
          <VitalSignsForm
            :loading="recordingVitals"
            :error="vitalsError"
            @submit="onRecordVitals"
            @cancel="showVitalsForm = false"
          />
        </div>

        <VitalSignsHistory :vitals="vitals || []" :loading="vitalsLoading" />
      </div>

      <!-- Care plan tab -->
      <div v-else-if="activeTab === 'plan'">
        <div class="bg-white rounded-xl border border-gray-200 p-5">
          <!-- Plan ID input (if no plan loaded yet) -->
          <div v-if="!carePlanId && !carePlan" class="mb-4 flex gap-2">
            <input
              v-model="carePlanId"
              type="text"
              placeholder="ID du plan existant (optionnel)…"
              class="flex-1 px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
            />
          </div>

          <CarePlanPanel
            :hosp-id="hospId"
            :care-plan="carePlan"
            :loading="planLoading"
            :create-loading="creatingPlan"
            :create-error="createPlanError"
            :complete-loading="completingTask"
            @create="onCreatePlan"
            @complete-task="completeTask"
          />
        </div>
      </div>

      <!-- Notes tab -->
      <div v-else-if="activeTab === 'notes'">
        <div class="bg-white rounded-xl border border-gray-200 p-5">
          <NursingNotes
            :notes="notes || []"
            :loading="notesLoading"
            :add-loading="addingNote"
            :add-error="addNoteError"
            @add="addNote"
          />
        </div>
      </div>
    </template>
  </DashboardLayout>
</template>
