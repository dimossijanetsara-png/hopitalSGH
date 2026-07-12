import { ref } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { nursingService } from '@/services/nursing.service'

// ─── Care Plans ───────────────────────────────────────────────────────────────

export function useCarePlan(planId) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['careplan', planId],
    queryFn: async () => (await nursingService.getCarePlan(planId)).data,
    enabled: !!planId,
  })
  return { carePlan: data, loading: isLoading, refetch }
}

export function useCreateCarePlan(hospId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending, data } = useMutation({
    mutationFn: (payload) => nursingService.createCarePlan({ hospitalization_id: hospId, ...payload }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['careplan'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la création du plan.' },
  })
  return { submit: mutate, loading: isPending, error, result: data }
}

// ─── Tasks ────────────────────────────────────────────────────────────────────

export function useCompleteTask(planId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: ({ taskId, notes }) => nursingService.completeTask(taskId, { notes }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['careplan', planId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { complete: mutate, loading: isPending, error }
}

// ─── Vital Signs ──────────────────────────────────────────────────────────────

export function useVitalSigns(hospId) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['vitals', hospId],
    queryFn: async () => (await nursingService.listVitalSigns(hospId)).data,
    enabled: !!hospId,
  })
  return { vitals: data, loading: isLoading, refetch }
}

export function useRecordVitals(hospId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => nursingService.recordVitalSigns(hospId, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['vitals', hospId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la saisie.' },
  })
  return { submit: mutate, loading: isPending, error }
}

// ─── Nursing Notes ────────────────────────────────────────────────────────────

export function useNursingNotes(hospId) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['nursing-notes', hospId],
    queryFn: async () => (await nursingService.listNotes(hospId)).data,
    enabled: !!hospId,
  })
  return { notes: data, loading: isLoading, refetch }
}

export function useAddNote(hospId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => nursingService.addNote(hospId, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['nursing-notes', hospId] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}
