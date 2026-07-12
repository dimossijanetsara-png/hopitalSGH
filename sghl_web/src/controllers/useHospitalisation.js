import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { useRouter } from 'vue-router'
import { hospitalisationService } from '@/services/hospitalisation.service'

// ─── Infrastructure ───────────────────────────────────────────────────────────

export function useBuildings() {
  const { data, isLoading } = useQuery({
    queryKey: ['buildings'],
    queryFn: async () => (await hospitalisationService.listBuildings()).data,
  })
  return { buildings: data, loading: isLoading }
}

export function useCreateBuilding() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.createBuilding(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['buildings'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useDepartments(buildingId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['departments', buildingId?.value]),
    queryFn: async () =>
      (await hospitalisationService.listDepartments(
        buildingId?.value ? { building_id: buildingId.value } : {},
      )).data,
  })
  return { departments: data, loading: isLoading }
}

export function useCreateDepartment() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.createDepartment(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['departments'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useRooms(departmentId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['rooms', departmentId?.value]),
    queryFn: async () =>
      (await hospitalisationService.listRooms(
        departmentId?.value ? { department_id: departmentId.value } : {},
      )).data,
    enabled: computed(() => !!departmentId?.value),
  })
  return { rooms: data, loading: isLoading }
}

export function useCreateRoom() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.createRoom(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['rooms'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useBeds(roomId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['beds', roomId?.value]),
    queryFn: async () =>
      (await hospitalisationService.listBeds(
        roomId?.value ? { room_id: roomId.value } : {},
      )).data,
    enabled: computed(() => !!roomId?.value),
  })
  return { beds: data, loading: isLoading }
}

export function useCreateBed() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.createBed(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['beds'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useAvailableBeds(departmentId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['beds', 'available', departmentId?.value]),
    queryFn: async () =>
      (await hospitalisationService.getAvailableBeds(
        departmentId?.value ? { department_id: departmentId.value } : {},
      )).data,
  })
  return { beds: data, loading: isLoading }
}

// ─── Admissions ───────────────────────────────────────────────────────────────

export function useAdmissionList(filters) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['admissions', filters?.value]),
    queryFn: async () =>
      (await hospitalisationService.listAdmissions(filters?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useAdmission(id) {
  const { data, isLoading, refetch } = useQuery({
    queryKey: computed(() => ['admissions', id?.value ?? id]),
    queryFn: async () =>
      (await hospitalisationService.getAdmission(id?.value ?? id)).data,
    enabled: computed(() => !!(id?.value ?? id)),
  })
  return { admission: data, loading: isLoading, refetch }
}

export function useCreateAdmission() {
  const qc = useQueryClient()
  const router = useRouter()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.createAdmission(data),
    onSuccess: ({ data }) => {
      qc.invalidateQueries({ queryKey: ['admissions'] })
      qc.invalidateQueries({ queryKey: ['beds'] })
      router.push({ name: 'admission-detail', params: { id: data.id } })
    },
    onError: (e) => { error.value = e.response?.data?.detail || "Erreur lors de l'admission." },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useDischarge(admissionId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.discharge(admissionId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admissions', admissionId] })
      qc.invalidateQueries({ queryKey: ['beds'] })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la sortie.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useTransfer(admissionId) {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hospitalisationService.transfer(admissionId, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admissions', admissionId] })
      qc.invalidateQueries({ queryKey: ['beds'] })
    },
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors du transfert.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useAdmissionFilters() {
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
