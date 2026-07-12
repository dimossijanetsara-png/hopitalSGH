import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { useRouter } from 'vue-router'
import { billingService } from '@/services/billing.service'

export function useInvoiceList(filters) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['invoices', filters?.value]),
    queryFn: async () => (await billingService.listInvoices(filters?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useInvoice(id) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: computed(() => ['invoices', id?.value ?? id]),
    queryFn: async () => (await billingService.getInvoice(id?.value ?? id)).data,
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { invoice: data, loading: isLoading, refetch }
}

export function useCreateInvoice() {
  const qc = useQueryClient()
  const router = useRouter()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => billingService.createInvoice(data),
    onSuccess: ({ data }) => {
      qc.invalidateQueries({ queryKey: ['invoices'] })
      router.push({ name: 'invoice-detail', params: { id: data.id } })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la création.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useIssueInvoice(invoiceId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: () => billingService.issueInvoice(invoiceId),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['invoices', invoiceId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { issue: mutate, loading: isPending, error }
}

export function usePayments(invoiceId) {
  const { data, isLoading } = useQuery({
    queryKey: ['payments', invoiceId],
    queryFn: async () => (await billingService.listPayments(invoiceId)).data,
    enabled: !!invoiceId,
  })
  return { payments: data, loading: isLoading }
}

export function useAddPayment(invoiceId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => billingService.addPayment(invoiceId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['payments', invoiceId] })
      qc.invalidateQueries({ queryKey: ['invoices', invoiceId] })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors du paiement.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useInvoiceFilters() {
  const status = ref('')
  const patientId = ref('')
  const page = ref(1)
  const filters = computed(() => ({
    status: status.value || undefined,
    patient_id: patientId.value || undefined,
    page: page.value,
  }))
  return { status, patientId, page, filters }
}
