<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import PatientForm from '@/components/patients/PatientForm.vue'
import { usePatient, useCreatePatient, useUpdatePatient } from '@/controllers/usePatients'

const route = useRoute()
const patientId = route.params.id
const isEdit = computed(() => !!patientId)

const { patient, loading: loadingPatient } = isEdit.value
  ? usePatient(patientId)
  : { patient: null, loading: false }

const {
  submit: create,
  loading: creating,
  error: createError,
} = useCreatePatient()

const {
  submit: update,
  loading: updating,
  error: updateError,
  success: updateSuccess,
} = isEdit.value ? useUpdatePatient(patientId) : { submit: null, loading: false, error: null, success: false }

function handleSubmit(data) {
  if (isEdit.value) update(data)
  else create(data)
}
</script>

<template>
  <DashboardLayout>
    <div class="max-w-3xl mx-auto">
      <div class="flex items-center gap-3 mb-6">
        <RouterLink
          :to="isEdit ? `/patients/${patientId}` : '/patients'"
          class="p-2 rounded-lg hover:bg-gray-100 text-gray-500"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </RouterLink>
        <h1 class="text-2xl font-bold text-gray-900">
          {{ isEdit ? 'Modifier le patient' : 'Nouveau patient' }}
        </h1>
      </div>

      <div v-if="isEdit && loadingPatient" class="flex justify-center py-20">
        <AppSpinner size="lg" />
      </div>

      <div v-else class="bg-white rounded-xl border border-gray-200 p-6">
        <PatientForm
          :initial="isEdit ? patient : null"
          :loading="isEdit ? updating : creating"
          :error="isEdit ? updateError : createError"
          :success="isEdit ? updateSuccess : false"
          @submit="handleSubmit"
        >
          <template #actions>
            <RouterLink :to="isEdit ? `/patients/${patientId}` : '/patients'">
              <AppButton variant="secondary" type="button">Annuler</AppButton>
            </RouterLink>
          </template>
        </PatientForm>
      </div>
    </div>
  </DashboardLayout>
</template>
