import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { useRouter } from 'vue-router'
import { patientService } from '@/services/patient.service'

export function usePatientList(filters) {
  const { data, isLoading, isError } = useQuery({
    queryKey: computed(() => ['patients', filters?.value]),
    queryFn: async () => {
      const { data } = await patientService.list(filters?.value || {})
      return data
    },
  })
  return { data, loading: isLoading, error: isError }
}

export function usePatient(id) {
  const { data, isLoading, isError } = useQuery({
    queryKey: computed(() => ['patients', id?.value ?? id]),
    queryFn: async () => {
      const { data } = await patientService.get(id?.value ?? id)
      return data
    },
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { patient: data, loading: isLoading, error: isError }
}

export function usePatientDocuments(id) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: computed(() => ['patients', id?.value ?? id, 'documents']),
    queryFn: async () => {
      const { data } = await patientService.listDocuments(id?.value ?? id)
      return data
    },
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { documents: data, loading: isLoading, refetch }
}

export function useCreatePatient() {
  const qc = useQueryClient()
  const router = useRouter()
  const error = ref(null)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) => patientService.create(data),
    onSuccess: ({ data }) => {
      qc.invalidateQueries({ queryKey: ['patients'] })
      router.push({ name: 'patient-detail', params: { id: data.id } })
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || 'Erreur lors de la création.'
    },
  })

  return { submit: mutate, loading: isPending, error }
}

export function useUpdatePatient(id) {
  const qc = useQueryClient()
  const error = ref(null)
  const success = ref(false)

  const { mutate, isPending } = useMutation({
    mutationFn: (data) => patientService.update(id?.value ?? id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients', id?.value ?? id] })
      qc.invalidateQueries({ queryKey: ['patients'] })
      success.value = true
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || 'Erreur lors de la mise à jour.'
    },
  })

  return { submit: mutate, loading: isPending, error, success }
}

export function useArchivePatient() {
  const qc = useQueryClient()
  const router = useRouter()

  const { mutate, isPending } = useMutation({
    mutationFn: (id) => patientService.archive(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients'] })
      router.push({ name: 'patients' })
    },
  })

  return { archive: mutate, loading: isPending }
}

export function useUploadDocument(patientId) {
  const qc = useQueryClient()
  const error = ref(null)
  const success = ref(false)

  const { mutate, isPending } = useMutation({
    mutationFn: (formData) => patientService.uploadDocument(patientId?.value ?? patientId, formData),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients', patientId?.value ?? patientId, 'documents'] })
      success.value = true
    },
    onError: (err) => {
      error.value = err.response?.data?.detail || "Erreur lors de l'upload."
    },
  })

  return { upload: mutate, loading: isPending, error, success }
}

export function usePatientSearch() {
  const search = ref('')
  const showArchived = ref(false)
  const page = ref(1)

  const filters = computed(() => ({
    search: search.value || undefined,
    archived: showArchived.value || undefined,
    page: page.value,
  }))

  return { search, showArchived, page, filters }
}
