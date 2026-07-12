<script setup>
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AdmissionForm from '@/components/hospitalisation/AdmissionForm.vue'
import { useCreateAdmission } from '@/controllers/useHospitalisation'

const route = useRoute()
const { submit, loading, error } = useCreateAdmission()
</script>

<template>
  <DashboardLayout>
    <div class="max-w-2xl mx-auto">
      <div class="flex items-center gap-3 mb-6">
        <RouterLink to="/hospitalisation" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </RouterLink>
        <h1 class="text-2xl font-bold text-gray-900">Nouvelle admission</h1>
      </div>

      <div class="bg-white rounded-xl border border-gray-200 p-6">
        <AdmissionForm
          :patient-id="route.query.patient"
          :loading="loading"
          :error="error"
          @submit="submit"
          @cancel="$router.push('/hospitalisation')"
        />
      </div>
    </div>
  </DashboardLayout>
</template>
