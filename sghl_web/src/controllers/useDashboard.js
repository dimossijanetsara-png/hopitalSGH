import { useQuery } from '@tanstack/vue-query'
import { dashboardService } from '@/services/dashboard.service'

export function useKpis() {
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['dashboard', 'kpis'],
    queryFn: async () => {
      const { data } = await dashboardService.getKpis()
      return data
    },
    staleTime: 1000 * 60,
    refetchInterval: 1000 * 60,
  })
  return { kpis: data, loading: isLoading, error: isError, refetch }
}

export function useHospitalisationStats() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard', 'hospitalisation-stats'],
    queryFn: async () => {
      const { data } = await dashboardService.getHospitalisationStats()
      return data
    },
    staleTime: 1000 * 60 * 5,
  })
  return { stats: data, loading: isLoading, error: isError }
}

export function useRevenueStats() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard', 'revenue-stats'],
    queryFn: async () => {
      const { data } = await dashboardService.getRevenueStats()
      return data
    },
    staleTime: 1000 * 60 * 5,
  })
  return { stats: data, loading: isLoading, error: isError }
}
