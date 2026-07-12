import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { hrService } from '@/services/hr.service'

export function useStaffList(departmentId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['staff', departmentId?.value]),
    queryFn: async () =>
      (await hrService.listStaff(departmentId?.value ? { department_id: departmentId.value } : {})).data,
  })
  return { data, loading: isLoading }
}

export function useCreateStaff() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hrService.createStaff(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useShiftList(filters) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['shifts', filters?.value]),
    queryFn: async () => (await hrService.listShifts(filters?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useCreateShift() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => hrService.createShift(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['shifts'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useConfirmShift() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (id) => hrService.confirmShift(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['shifts'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { confirm: mutate, loading: isPending, error }
}

export function useShiftFilters() {
  const departmentId = ref('')
  const staffId = ref('')
  const filters = computed(() => ({
    department_id: departmentId.value || undefined,
    staff_id: staffId.value || undefined,
  }))
  return { departmentId, staffId, filters }
}
