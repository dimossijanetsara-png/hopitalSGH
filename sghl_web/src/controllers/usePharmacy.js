import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { pharmacyService } from '@/services/pharmacy.service'

// ─── Medications ──────────────────────────────────────────────────────────────

export function useMedications(params) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['medications', params?.value]),
    queryFn: async () => (await pharmacyService.listMedications(params?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useMedication(id) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['medications', id?.value ?? id]),
    queryFn: async () => (await pharmacyService.getMedication(id?.value ?? id)).data,
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { medication: data, loading: isLoading }
}

export function useLowStockAlerts() {
  const { data, isLoading } = useQuery({
    queryKey: ['medications', 'low-stock'],
    queryFn: async () => (await pharmacyService.getLowStockAlerts()).data,
    refetchInterval: 5 * 60 * 1000,
  })
  return { alerts: data, loading: isLoading }
}

// ─── Batches ──────────────────────────────────────────────────────────────────

export function useBatches(medicationId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['batches', medicationId?.value]),
    queryFn: async () =>
      (await pharmacyService.listBatches(
        medicationId?.value ? { medication_id: medicationId.value } : {},
      )).data,
    enabled: computed(() => !!(medicationId?.value)),
  })
  return { batches: data, loading: isLoading }
}

export function useReceiveBatch() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => pharmacyService.receiveBatch(data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['batches'] })
      qc.invalidateQueries({ queryKey: ['medications'] })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la réception.' },
  })
  return { submit: mutate, loading: isPending, error }
}

// ─── Dispensations ────────────────────────────────────────────────────────────

export function useCreateDispensation() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => pharmacyService.createDispensation(data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['batches'] })
      qc.invalidateQueries({ queryKey: ['medications'] })
      qc.invalidateQueries({ queryKey: ['movements'] })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la dispensation.' },
  })
  return { submit: mutate, loading: isPending, error }
}

// ─── Stock Movements ──────────────────────────────────────────────────────────

export function useStockMovements(medicationId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['movements', medicationId?.value]),
    queryFn: async () =>
      (await pharmacyService.listMovements(
        medicationId?.value ? { medication_id: medicationId.value } : {},
      )).data,
  })
  return { movements: data, loading: isLoading }
}

// ─── Filters ──────────────────────────────────────────────────────────────────

export function useMedicationFilters() {
  const search = ref('')
  const lowStock = ref(false)
  const params = computed(() => ({
    search: search.value || undefined,
    low_stock: lowStock.value || undefined,
  }))
  return { search, lowStock, params }
}
