<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import DashboardLayout from '@/layouts/DashboardLayout.vue'
import AppBadge from '@/components/ui/AppBadge.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import AppModal from '@/components/ui/AppModal.vue'
import PaymentForm from '@/components/billing/PaymentForm.vue'
import {
  useInvoice, useIssueInvoice, usePayments, useAddPayment,
} from '@/controllers/useBilling'
import {
  INVOICE_STATUSES, INVOICE_STATUS_COLORS,
  ITEM_TYPES, PAYMENT_METHODS, PAYMENT_METHOD_COLORS,
  formatMoney,
} from '@/models/billing.model'

const route = useRoute()
const invoiceId = route.params.id

const { invoice, loading } = useInvoice(invoiceId)
const { issue, loading: issuing, error: issueError } = useIssueInvoice(invoiceId)
const { payments, loading: paymentsLoading } = usePayments(invoiceId)
const { submit: addPayment, loading: paying, error: paymentError } = useAddPayment(invoiceId)

const showPaymentModal = ref(false)

function handlePayment(data) {
  addPayment(data, { onSuccess: () => { showPaymentModal.value = false } })
}

const canIssue = computed(() => invoice.value?.status === 'DRAFT')
const canPay = computed(() => ['ISSUED', 'PARTIALLY_PAID'].includes(invoice.value?.status))

function statusLabel(v) {
  return INVOICE_STATUSES.find((s) => s.value === v)?.label || v
}

function itemTypeLabel(v) {
  return ITEM_TYPES.find((t) => t.value === v)?.label || v
}

function methodLabel(v) {
  return PAYMENT_METHODS.find((m) => m.value === v)?.label || v
}

function formatDate(d) {
  if (!d) return '–'
  return new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatDatetime(d) {
  if (!d) return '–'
  return new Date(d).toLocaleString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const paymentsList = computed(() => payments.value?.results || payments.value || [])
</script>

<template>
  <DashboardLayout>
    <div v-if="loading" class="flex justify-center py-20"><AppSpinner size="xl" /></div>

    <div v-else-if="invoice">
      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-start justify-between gap-4 mb-6">
        <div class="flex items-center gap-3">
          <RouterLink to="/facturation" class="p-2 rounded-lg hover:bg-gray-100 text-gray-500">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </RouterLink>
          <div>
            <h1 class="text-2xl font-bold text-gray-900">
              Facture {{ invoice.invoice_number || '#' + invoice.id?.slice(0, 8) }}
            </h1>
            <p class="text-sm text-gray-500 mt-0.5">
              {{ invoice.patient?.full_name || invoice.patient_id }} · {{ formatDate(invoice.created_at) }}
            </p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <AppBadge :color-class="INVOICE_STATUS_COLORS[invoice.status] || 'bg-gray-100 text-gray-600'">
            {{ statusLabel(invoice.status) }}
          </AppBadge>
          <AppButton v-if="canIssue" size="sm" :loading="issuing" @click="issue()">Émettre</AppButton>
          <AppButton v-if="canPay" size="sm" @click="showPaymentModal = true">
            Enregistrer paiement
          </AppButton>
        </div>
      </div>

      <AppAlert v-if="issueError" type="error" :message="issueError" class="mb-4" />

      <!-- Summary cards -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-xl border border-gray-200 p-4 text-center">
          <p class="text-xs text-gray-400 mb-1">Sous-total</p>
          <p class="text-lg font-bold text-gray-800">{{ formatMoney(invoice.subtotal) }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4 text-center">
          <p class="text-xs text-gray-400 mb-1">Remise</p>
          <p class="text-lg font-bold text-orange-600">− {{ formatMoney(invoice.discount) }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4 text-center">
          <p class="text-xs text-gray-400 mb-1">Total TTC</p>
          <p class="text-lg font-bold text-gray-900">{{ formatMoney(invoice.total) }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-200 p-4 text-center"
          :class="parseFloat(invoice.balance_due) > 0 ? 'border-orange-300 bg-orange-50' : 'border-green-300 bg-green-50'">
          <p class="text-xs text-gray-400 mb-1">Solde restant</p>
          <p class="text-lg font-bold" :class="parseFloat(invoice.balance_due) > 0 ? 'text-orange-700' : 'text-green-700'">
            {{ formatMoney(invoice.balance_due) }}
          </p>
        </div>
      </div>

      <!-- Insurance -->
      <div v-if="invoice.insurance_provider" class="bg-teal-50 border border-teal-200 rounded-xl p-4 mb-6 flex flex-wrap gap-4 text-sm">
        <div>
          <span class="text-teal-600 font-medium">Assurance :</span>
          <span class="ml-1 text-gray-700">{{ invoice.insurance_provider }}</span>
        </div>
        <div>
          <span class="text-teal-600 font-medium">Prise en charge :</span>
          <span class="ml-1 text-gray-700">{{ formatMoney(invoice.insurance_coverage) }}</span>
        </div>
        <div v-if="invoice.insurance_claim_number">
          <span class="text-teal-600 font-medium">N° dossier :</span>
          <span class="ml-1 text-gray-700">{{ invoice.insurance_claim_number }}</span>
        </div>
      </div>

      <!-- Items table -->
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden mb-6">
        <div class="px-4 py-3 border-b border-gray-100">
          <h3 class="font-semibold text-gray-800">Articles ({{ invoice.items?.length || 0 }})</h3>
        </div>
        <table class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Type</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Description</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Qté</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">P.U.</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Remise</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Total</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="item in invoice.items" :key="item.id">
              <td class="px-4 py-3">
                <AppBadge color-class="bg-gray-100 text-gray-600">{{ itemTypeLabel(item.item_type) }}</AppBadge>
              </td>
              <td class="px-4 py-3 text-gray-700">{{ item.description }}</td>
              <td class="px-4 py-3 text-right text-gray-700">{{ item.quantity }}</td>
              <td class="px-4 py-3 text-right text-gray-700">{{ formatMoney(item.unit_price) }}</td>
              <td class="px-4 py-3 text-right text-orange-500">
                {{ parseFloat(item.discount_percent) > 0 ? item.discount_percent + '%' : '–' }}
              </td>
              <td class="px-4 py-3 text-right font-semibold text-gray-900">{{ formatMoney(item.total_price) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Payments -->
      <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
          <h3 class="font-semibold text-gray-800">Paiements</h3>
          <span class="text-sm text-gray-500">
            Encaissé : <strong class="text-green-700">{{ formatMoney(invoice.amount_paid) }}</strong>
          </span>
        </div>
        <div v-if="paymentsLoading" class="flex justify-center py-8"><AppSpinner /></div>
        <div v-else-if="!paymentsList.length" class="text-center py-8 text-gray-400 text-sm">
          Aucun paiement enregistré
        </div>
        <table v-else class="w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Mode</th>
              <th class="text-right px-4 py-3 font-medium text-gray-600">Montant</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Référence</th>
              <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="pay in paymentsList" :key="pay.id">
              <td class="px-4 py-3">
                <AppBadge :color-class="PAYMENT_METHOD_COLORS[pay.method] || 'bg-gray-100 text-gray-600'">
                  {{ methodLabel(pay.method) }}
                </AppBadge>
              </td>
              <td class="px-4 py-3 text-right font-semibold text-green-700">{{ formatMoney(pay.amount) }}</td>
              <td class="px-4 py-3 text-gray-500 text-xs">{{ pay.reference || '–' }}</td>
              <td class="px-4 py-3 text-gray-400 text-xs">{{ formatDatetime(pay.created_at) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Payment modal -->
    <AppModal :open="showPaymentModal" title="Enregistrer un paiement" size="md" @close="showPaymentModal = false">
      <PaymentForm
        :balance-due="invoice?.balance_due"
        :loading="paying"
        :error="paymentError"
        @submit="handlePayment"
        @cancel="showPaymentModal = false"
      />
    </AppModal>
  </DashboardLayout>
</template>
