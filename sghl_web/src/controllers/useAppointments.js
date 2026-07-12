import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { appointmentsService } from '@/services/appointments.service'

export function useAppointmentList(filters) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['appointments', filters?.value]),
    queryFn: async () => (await appointmentsService.listAppointments(filters?.value || {})).data,
  })
  return { data, loading: isLoading }
}

export function useCreateAppointment() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: (data) => appointmentsService.createAppointment(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['appointments'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur lors de la création.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useUpdateAppointment() {
  const qc = useQueryClient()
  const error = ref(null)
  const { mutate, isPending } = useMutation({
    mutationFn: ({ id, data }) => appointmentsService.updateAppointment(id, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['appointments'] }),
    onError: (e) => { error.value = e.response?.data?.detail || 'Erreur.' },
  })
  return { submit: mutate, loading: isPending, error }
}

export function useDoctorAvailability(doctorId) {
  const { data, isLoading } = useQuery({
    queryKey: computed(() => ['availability', doctorId?.value ?? doctorId]),
    queryFn: async () => (await appointmentsService.getDoctorAvailability(doctorId?.value ?? doctorId)).data,
    enabled: computed(() => !!(doctorId?.value ?? doctorId)),
  })
  return { availability: data, loading: isLoading }
}

export function useAppointmentFilters() {
  const status = ref('')
  const doctorId = ref('')
  const patientId = ref('')
  const page = ref(1)
  const filters = computed(() => ({
    status: status.value || undefined,
    doctor_id: doctorId.value || undefined,
    patient_id: patientId.value || undefined,
    page: page.value,
  }))
  return { status, doctorId, patientId, page, filters }
}
