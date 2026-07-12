<script setup>
import { ref } from 'vue'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { exportToExcel, exportMultiSheet, PATIENT_COLUMNS, APPOINTMENT_COLUMNS, LAB_ORDER_COLUMNS, INVOICE_COLUMNS, HOSPITALIZATION_COLUMNS, STAFF_COLUMNS } from '@/utils/export'
import { patientService } from '@/services/patient.service'
import { appointmentsService } from '@/services/appointments.service'
import { laboratoryService } from '@/services/laboratory.service'
import { billingService } from '@/services/billing.service'
import { hospitalisationService } from '@/services/hospitalisation.service'
import { hrService } from '@/services/hr.service'

const loading = ref({})
const lastExport = ref({})

async function fetchAll(serviceFn, params = {}) {
  let all = []
  let page = 1
  while (true) {
    const { data } = await serviceFn({ ...params, page, page_size: 200 })
    const results = data?.results || data || []
    all = all.concat(results)
    if (!data?.count || all.length >= data.count) break
    page++
  }
  return all
}

async function exportModule(key, label, serviceFn, columns, params) {
  loading.value[key] = true
  try {
    const data = await fetchAll(serviceFn, params)
    exportToExcel(data, columns, label)
    lastExport.value[key] = new Date().toLocaleTimeString('fr-FR')
  } catch (e) {
    console.error(e)
  } finally {
    loading.value[key] = false
  }
}

async function exportAll() {
  loading.value.all = true
  try {
    const [patients, appointments, labOrders, invoices, hospitalizations, staff] = await Promise.all([
      fetchAll(patientService.list),
      fetchAll(appointmentsService.listAppointments),
      fetchAll(laboratoryService.listOrders),
      fetchAll(billingService.listInvoices),
      fetchAll(hospitalisationService.listAdmissions),
      fetchAll(hrService.listStaff),
    ])
    exportMultiSheet([
      { name: 'Patients', data: patients, columns: PATIENT_COLUMNS },
      { name: 'Rendez-vous', data: appointments, columns: APPOINTMENT_COLUMNS },
      { name: 'Commandes Labo', data: labOrders, columns: LAB_ORDER_COLUMNS },
      { name: 'Facturation', data: invoices, columns: INVOICE_COLUMNS },
      { name: 'Hospitalisations', data: hospitalizations, columns: HOSPITALIZATION_COLUMNS },
      { name: 'Personnel', data: staff, columns: STAFF_COLUMNS },
    ], 'SGHL_export_complet')
    lastExport.value.all = new Date().toLocaleTimeString('fr-FR')
  } catch (e) {
    console.error(e)
  } finally {
    loading.value.all = false
  }
}

const modules = [
  {
    key: 'patients',
    label: 'Patients',
    icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z',
    color: 'bg-blue-50 text-blue-600 border-blue-200',
    btnColor: 'bg-blue-600 hover:bg-blue-700',
    fn: () => exportModule('patients', 'patients', patientService.list, PATIENT_COLUMNS),
  },
  {
    key: 'appointments',
    label: 'Rendez-vous',
    icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    color: 'bg-indigo-50 text-indigo-600 border-indigo-200',
    btnColor: 'bg-indigo-600 hover:bg-indigo-700',
    fn: () => exportModule('appointments', 'rendez-vous', appointmentsService.listAppointments, APPOINTMENT_COLUMNS),
  },
  {
    key: 'labOrders',
    label: 'Laboratoire',
    icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z',
    color: 'bg-purple-50 text-purple-600 border-purple-200',
    btnColor: 'bg-purple-600 hover:bg-purple-700',
    fn: () => exportModule('labOrders', 'laboratoire', laboratoryService.listOrders, LAB_ORDER_COLUMNS),
  },
  {
    key: 'invoices',
    label: 'Facturation',
    icon: 'M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z',
    color: 'bg-emerald-50 text-emerald-600 border-emerald-200',
    btnColor: 'bg-emerald-600 hover:bg-emerald-700',
    fn: () => exportModule('invoices', 'facturation', billingService.listInvoices, INVOICE_COLUMNS),
  },
  {
    key: 'hospitalizations',
    label: 'Hospitalisations',
    icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
    color: 'bg-orange-50 text-orange-600 border-orange-200',
    btnColor: 'bg-orange-600 hover:bg-orange-700',
    fn: () => exportModule('hospitalizations', 'hospitalisations', hospitalisationService.listAdmissions, HOSPITALIZATION_COLUMNS),
  },
  {
    key: 'staff',
    label: 'Personnel RH',
    icon: 'M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    color: 'bg-rose-50 text-rose-600 border-rose-200',
    btnColor: 'bg-rose-600 hover:bg-rose-700',
    fn: () => exportModule('staff', 'personnel', hrService.listStaff, STAFF_COLUMNS),
  },
]
</script>

<template>
  <DashboardLayout>
    <div class="max-w-4xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Export des données</h1>
        <p class="text-sm text-gray-500 mt-1">Exportez les données de l'application au format Excel (.xlsx)</p>
      </div>

      <!-- Export global -->
      <div class="bg-linear-to-r from-blue-600 to-blue-700 rounded-2xl p-6 mb-8 text-white shadow-sm">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="text-lg font-semibold mb-1">Export complet de l'application</h2>
            <p class="text-blue-200 text-sm">
              Génère un fichier Excel multi-feuilles avec toutes les données de tous les modules.
            </p>
            <p v-if="lastExport.all" class="text-blue-300 text-xs mt-1">
              Dernier export : {{ lastExport.all }}
            </p>
          </div>
          <AppButton
            :loading="loading.all"
            class="bg-white text-blue-700 hover:bg-blue-50 border-0 shrink-0"
            @click="exportAll"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Tout exporter
          </AppButton>
        </div>
      </div>

      <!-- Modules individuels -->
      <h2 class="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">Export par module</h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="mod in modules"
          :key="mod.key"
          :class="['rounded-xl border p-5', mod.color]"
        >
          <div class="flex items-start justify-between mb-4">
            <svg class="w-8 h-8 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="mod.icon" />
            </svg>
            <div v-if="loading[mod.key]">
              <AppSpinner size="sm" />
            </div>
          </div>

          <p class="font-semibold text-gray-900 mb-1">{{ mod.label }}</p>
          <p v-if="lastExport[mod.key]" class="text-xs text-gray-400 mb-3">
            Dernier export : {{ lastExport[mod.key] }}
          </p>

          <button
            :disabled="loading[mod.key]"
            class="mt-2 w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-white transition-colors disabled:opacity-50"
            :class="mod.btnColor"
            @click="mod.fn"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            Exporter Excel
          </button>
        </div>
      </div>

      <!-- Note -->
      <div class="mt-8 bg-gray-50 rounded-xl p-4 border border-gray-200">
        <p class="text-xs text-gray-500">
          <strong>Note :</strong> L'export récupère toutes les données disponibles selon vos droits d'accès.
          Les fichiers générés sont au format <code>.xlsx</code> compatible avec Microsoft Excel, LibreOffice Calc et Google Sheets.
        </p>
      </div>
    </div>
  </DashboardLayout>
</template>
