<script setup>
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import { PRESCRIPTION_STATUS_COLORS } from '@/models/clinical.model'
import { useValidatePrescription } from '@/controllers/useClinical'
import { useAuthStore } from '@/stores/auth.store'
import { formatDate } from '@/models/patient.model'

const props = defineProps({ prescription: { type: Object, required: true } })
const auth = useAuthStore()
const { validate, loading } = useValidatePrescription()
const isDoctor = ['DOCTOR', 'ADMIN'].includes(auth.currentRole)
</script>

<template>
  <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
    <!-- Header ordonnance -->
    <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-gray-50">
      <div class="flex items-center gap-3">
        <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <span class="text-sm font-medium text-gray-700">Ordonnance</span>
        <AppBadge
          :label="prescription.status"
          :color="PRESCRIPTION_STATUS_COLORS[prescription.status]"
        />
      </div>
      <div class="flex items-center gap-3">
        <span v-if="prescription.validated_at" class="text-xs text-gray-400">
          Validée le {{ formatDate(prescription.validated_at) }}
        </span>
        <AppButton
          v-if="prescription.status === 'DRAFT' && isDoctor"
          size="sm"
          variant="success"
          :loading="loading"
          @click="validate(prescription.id)"
        >
          Valider
        </AppButton>
      </div>
    </div>

    <!-- Items -->
    <div class="divide-y divide-gray-100">
      <div
        v-for="item in prescription.items"
        :key="item.id"
        class="px-4 py-3 flex items-start gap-4"
      >
        <div class="w-8 h-8 bg-blue-50 rounded-lg flex items-center justify-center shrink-0">
          <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
          </svg>
        </div>
        <div class="flex-1">
          <p class="text-sm font-semibold text-gray-900">
            {{ item.medication_name }}
            <span class="text-gray-500 font-normal">{{ item.dosage }}</span>
          </p>
          <div class="flex flex-wrap gap-3 mt-1 text-xs text-gray-500">
            <span>{{ item.frequency }}</span>
            <span v-if="item.duration">· {{ item.duration }}</span>
            <span v-if="item.route">· Voie : {{ item.route }}</span>
            <span v-if="item.quantity">· Qté : {{ item.quantity }}</span>
          </div>
          <p v-if="item.instructions" class="text-xs text-blue-600 mt-1 italic">
            {{ item.instructions }}
          </p>
        </div>
      </div>
    </div>

    <div v-if="prescription.notes" class="px-4 py-2 bg-gray-50 border-t border-gray-100">
      <p class="text-xs text-gray-500 italic">{{ prescription.notes }}</p>
    </div>
  </div>
</template>
