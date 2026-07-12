import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { useRouter } from 'vue-router'
import { laboratoryService } from '@/services/laboratory.service'

// ─── Catalog ──────────────────────────────────────────────────────────────────

export function useLabTests() {
  const { data, isLoading } = useQuery({
    queryKey: ['lab-tests'],
    queryFn: async () => (await laboratoryService.listTests()).data,
    staleTime: 10 * 60 * 1000,
  })
  return { tests: data, loading: isLoading }
}

// ─── Orders ───────────────────────────────────────────────────────────────────

export function useLabOrderList(filters) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['lab-orders', filters?.value]),
    queryFn: async () => (await laboratoryService.listOrders(filters?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useLabOrder(id) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: computed(() => ['lab-orders', id?.value ?? id]),
    queryFn: async () => (await laboratoryService.getOrder(id?.value ?? id)).data,
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { order: data, loading: isLoading, refetch }
}

export function useCreateLabOrder() {
  const qc = useQueryClient()
  const router = useRouter()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => laboratoryService.createOrder(data),
    onSuccess: ({ data }) => {
      qc.invalidateQueries({ queryKey: ['lab-orders'] })
      router.push({ name: 'lab-order-detail', params: { id: data.id } })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la commande.' },
  })
  return { submit: mutate, loading: isPending, error }
}

// ─── Workflow actions ─────────────────────────────────────────────────────────

function makeWorkflowMutation(fn, orderId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: fn,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['lab-orders', orderId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { run: mutate, loading: isPending, error }
}

export function useSampleOrder(orderId) {
  return makeWorkflowMutation(() => laboratoryService.sample(orderId), orderId)
}

export function useAssignOrder(orderId) {
  return makeWorkflowMutation(
    (data) => laboratoryService.assign(orderId, data),
    orderId,
  )
}

export function useEnterResults(orderId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (items) => laboratoryService.enterResults(orderId, items),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['lab-orders', orderId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useValidateOrder(orderId) {
  return makeWorkflowMutation(() => laboratoryService.validate(orderId), orderId)
}

export function usePublishOrder(orderId) {
  return makeWorkflowMutation(() => laboratoryService.publish(orderId), orderId)
}

// ─── Filters ──────────────────────────────────────────────────────────────────

export function useLabOrderFilters() {
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
