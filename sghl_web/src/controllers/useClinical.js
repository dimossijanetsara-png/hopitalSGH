import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { useRouter } from 'vue-router'
import { clinicalService } from '@/services/clinical.service'

export function useConsultationList(filters) {
  const { data, isLoading, isError } = useQuery({
    queryKey: computed(() => ['consultations', filters?.value]),
    queryFn: async () => {
      const { data } = await clinicalService.listConsultations(filters?.value || {})
      return data
    },
  })
  return { data, loading: isLoading, error: isError }
}

export function useConsultation(id) {
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: computed(() => ['consultations', id?.value ?? id]),
    queryFn: async () => {
      const { data } = await clinicalService.getConsultation(id?.value ?? id)
      return data
    },
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { consultation: data, loading: isLoading, error: isError, refetch }
}

export function useCreateConsultation() {
  const qc = useQueryClient()
  const router = useRouter()
  const error = ref(null)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) => clinicalService.createConsultation(data),
    onSuccess: ({ data }) => {
      qc.invalidateQueries({ queryKey: ['consultations'] })
      router.push({ name: 'consultation-detail', params: { id: data.id } })
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || 'Erreur lors de la création.'
    },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useUpdateConsultation(id) {
  const qc = useQueryClient()
  const error = ref(null)
  const success = ref(false)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) => clinicalService.updateConsultation(id?.value ?? id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['consultations', id?.value ?? id] })
      success.value = true
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || 'Erreur lors de la mise à jour.'
    },
  })
  return { submit: mutate, loading: isPending, error, success }
}

export function useAddDiagnosis(consultationId) {
  const qc = useQueryClient()
  const error = ref(null)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) => clinicalService.addDiagnosis(consultationId?.value ?? consultationId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['consultations', consultationId?.value ?? consultationId] })
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || "Erreur lors de l'ajout du diagnostic."
    },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useCreatePrescription(consultationId) {
  const qc = useQueryClient()
  const error = ref(null)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) =>
      clinicalService.createPrescription(consultationId?.value ?? consultationId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['consultations', consultationId?.value ?? consultationId] })
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || "Erreur lors de la création de l'ordonnance."
    },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useValidatePrescription() {
  const qc = useQueryClient()
  const error = ref(null)

  const { mutate, isPending } = useMutation({
    mutationFn: (prescriptionId) => clinicalService.validatePrescription(prescriptionId),
    onSuccess: (_, prescriptionId) => {
      qc.invalidateQueries({ queryKey: ['consultations'] })
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || "Erreur lors de la validation."
    },
  })
  return { validate: mutate, loading: isPending, error }
}

export function useConsultationFilters() {
  const search = ref('')
  const patientId = ref('')
  const doctorId = ref('')
  const status = ref('')
  const page = ref(1)

  const filters = computed(() => ({
    search: search.value || undefined,
    patient_id: patientId.value || undefined,
    doctor_id: doctorId.value || undefined,
    status: status.value || undefined,
    page: page.value,
  }))

  return { search, patientId, doctorId, status, page, filters }
}
