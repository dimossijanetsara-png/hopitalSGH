<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppModal from '@/components/ui/AppModal.vue'
import LabResultsForm from '@/components/laboratory/LabResultsForm.vue'
import {
  useLabOrder,
  useSampleOrder, useAssignOrder,
  useEnterResults, useValidateOrder, usePublishOrder,
} from '@/controllers/useLaboratory'
import { useAuthStore } from '@/stores/auth.store'
import {
  LAB_ORDER_STATUSES, LAB_ORDER_STATUS_COLORS,
  LAB_PRIORITIES, LAB_PRIORITY_COLORS,
} from '@/models/laboratory.model'

const route = useRoute()
const auth = useAuthStore()
const orderId = route.params.id

const { order, loading } = useLabOrder(orderId)

const { run: sample, loading: sampling, error: sampleError } = useSampleOrder(orderId)
const { run: assign, loading: assigning, error: assignError } = useAssignOrder(orderId)
const { run: doValidate, loading: validating, error: validateError } = useValidateOrder(orderId)
const { run: doPublish, loading: publishing, error: publishError } = usePublishOrder(orderId)
const { submit: enterResults, loading: enteringResults, error: resultsError } = useEnterResults(orderId)

const showAssignModal = ref(false)
const showResultsForm = ref(false)
const biologistId = ref('')

function handleAssign() {
  assign({ biologist_id: biologistId.value }, { onSuccess: () => { showAssignModal.value = false } })
}

function handleResults(items) {
  enterResults(items, { onSuccess: () => { showResultsForm.value = false } })
}

const canSample = computed(() => order.value?.status === 'ORDERED')
const canAssign = computed(() => order.value?.status === 'SAMPLED')
const canEnterResults = computed(() => ['ASSIGNED', 'IN_PROGRESS'].includes(order.value?.status))
const canValidate = computed(() => order.value?.status === 'RESULTED' && auth.user?.role === 'BIOLOGIST' || auth.user?.role === 'ADMIN')
const canPublish = computed(() => order.value?.status === 'VALIDATED')

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function statusLabel(v) {
  return LAB_ORDER_STATUSES.find((s) => s.value === v)?.label || v
}
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20"><AppSpinner size="xl" /></div>

    <div v-else-if="order">
      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4 mb-6">
        <div class="flex items-center gap-3">
          <RouterLink to="/laboratoire" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Commande · {{ order.id?.slice(0, 8) }}</h1>
            <p class="text-sm text-gray-500 mt-0.5">{{ order.patient?.full_name || order.patient_id }}</p>
          </div>
        </div>

        <div class="flex flex-wrap items-center gap-2">
          <AppBadge :color-class="LAB_PRIORITY_COLORS[order.priority] || 'bg-gray-100 text-gray-600'">
            {{ LAB_PRIORITIES.find(p => p.value === order.priority)?.label }}
          </AppBadge>
          <AppBadge :color-class="LAB_ORDER_STATUS_COLORS[order.status] || 'bg-gray-100 text-gray-600'">
            {{ statusLabel(order.status) }}
          </AppBadge>
        </div>
      </div>

      <!-- Alerts -->
      <AppAlert v-if="sampleError" type="error" :message="sampleError" class="mb-4" />
      <AppAlert v-if="validateError" type="error" :message="validateError" class="mb-4" />
      <AppAlert v-if="publishError" type="error" :message="publishError" class="mb-4" />

      <!-- Workflow actions -->
      <div v-if="canSample || canAssign || canEnterResults || canValidate || canPublish"
        class="bg-white rounded-xl border border-gray-200 p-4 mb-6 flex flex-wrap gap-2">
        <p class="text-xs text-gray-400 w-full mb-1">Actions disponibles</p>
        <AppButton v-if="canSample" :loading="sampling" @click="sample()">Marquer prélevé</AppButton>
        <AppButton v-if="canAssign" @click="showAssignModal = true">Affecter biologiste</AppButton>
        <AppButton v-if="canEnterResults" variant="secondary" @click="showResultsForm = !showResultsForm">
          {{ showResultsForm ? 'Masquer' : 'Saisir les résultats' }}
        </AppButton>
        <AppButton v-if="canValidate" variant="success" :loading="validating" @click="doValidate()">Valider</AppButton>
        <AppButton v-if="canPublish" variant="success" :loading="publishing" @click="doPublish()">Publier</AppButton>
      </div>

      <!-- Results form inline -->
      <div v-if="showResultsForm" class="bg-white rounded-xl border border-blue-200 p-5 mb-6">
        <h3 class="font-semibold text-gray-800 mb-4">Saisie des résultats</h3>
        <LabResultsForm
          :items="order.items || []"
          :loading="enteringResults"
          :error="resultsError"
          @submit="handleResults"
          @cancel="showResultsForm = false"
        />
      </div>

      <!-- Info cards -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Commande</h3>
          <dl class="space-y-2 text-sm">
            <div class="flex justify-between">
              <dt class="text-gray-500">Date</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(order.created_at) }}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-gray-500">Prélevé le</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(order.sampled_at) }}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-gray-500">Validé le</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(order.validated_at) }}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="text-gray-500">Publié le</dt>
              <dd class="text-gray-900 font-medium">{{ formatDate(order.published_at) }}</dd>
            </div>
          </dl>
        </div>

        <div class="sm:col-span-2 bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-2">Notes cliniques</h3>
          <p class="text-sm text-gray-700 whitespace-pre-wrap">{{ order.clinical_notes || '–' }}</p>
        </div>
      </div>

      <!-- Results table -->
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100">
          <h3 class="font-semibold text-gray-800">Résultats ({{ order.items?.length || 0 }} analyse(s))</h3>
        </div>
        <table class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Analyse</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Résultat</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Unité</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Norme</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Statut</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr
              v-for="item in order.items"
              :key="item.id"
              :class="item.is_abnormal ? 'bg-red-50' : ''"
            >
              <td class="px-4 py-3">
                <p class="font-medium text-gray-800">{{ item.test?.name || item.test_id }}</p>
                <p class="text-xs text-gray-400">{{ item.test?.code }}</p>
              </td>
              <td class="px-4 py-3">
                <span :class="item.is_abnormal ? 'text-red-700 font-bold' : 'text-gray-900'">
                  {{ item.result_value || '–' }}
                </span>
              </td>
              <td class="px-4 py-3 text-gray-500">{{ item.result_unit || item.test?.unit || '–' }}</td>
              <td class="px-4 py-3 text-gray-400 text-xs">{{ item.test?.normal_range || '–' }}</td>
              <td class="px-4 py-3">
                <AppBadge v-if="item.is_abnormal" color-class="bg-red-100 text-red-700">Anormal</AppBadge>
                <span v-else-if="item.result_value" class="text-xs text-green-600">Normal</span>
                <span v-else class="text-xs text-gray-400">En attente</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Assign modal -->
    <AppModal :open="showAssignModal" title="Affecter un biologiste" size="sm" @close="showAssignModal = false">
      <div class="space-y-3">
        <AppAlert v-if="assignError" type="error" :message="assignError" />
        <label class="text-sm font-medium text-gray-700 block">
          ID Biologiste <span class="text-red-500">*</span>
        </label>
        <input
          v-model="biologistId"
          type="text"
          placeholder="UUID du biologiste"
          class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
      </div>
      <template #footer>
        <AppButton variant="secondary" @click="showAssignModal = false">Annuler</AppButton>
        <AppButton :loading="assigning" :disabled="!biologistId" @click="handleAssign">Affecter</AppButton>
      </template>
    </AppModal>
  </DashboardLayout>
</template>
