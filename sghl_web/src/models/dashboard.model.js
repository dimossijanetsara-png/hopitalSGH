export const KPI_DEFINITIONS = [
  {
    key: 'occupancy_rate',
    label: "Taux d'occupation",
    unit: '%',
    icon: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
    color: 'blue',
    format: (v) => `${v ?? 0}%`,
  },
  {
    key: 'active_hospitalizations',
    label: 'Hospitalisations actives',
    unit: '',
    icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z',
    color: 'teal',
    format: (v) => v ?? 0,
  },
  {
    key: 'monthly_revenue',
    label: 'Revenus du mois',
    unit: 'FCFA',
    icon: 'M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z',
    color: 'green',
    format: (v) => new Intl.NumberFormat('fr-FR').format(v ?? 0) + ' FCFA',
  },
  {
    key: 'pending_lab_orders',
    label: 'Analyses en attente',
    unit: '',
    icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z',
    color: 'orange',
    format: (v) => v ?? 0,
  },
  {
    key: 'today_appointments',
    label: "RDV aujourd'hui",
    unit: '',
    icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    color: 'purple',
    format: (v) => v ?? 0,
  },
  {
    key: 'available_beds',
    label: 'Lits disponibles',
    unit: '',
    icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
    color: 'slate',
    format: (v) => v ?? 0,
  },
]

export const KPI_COLOR_CLASSES = {
  blue: {
    bg: 'bg-blue-50',
    icon: 'bg-blue-100 text-blue-700',
    value: 'text-blue-700',
  },
  teal: {
    bg: 'bg-teal-50',
    icon: 'bg-teal-100 text-teal-700',
    value: 'text-teal-700',
  },
  green: {
    bg: 'bg-green-50',
    icon: 'bg-green-100 text-green-700',
    value: 'text-green-700',
  },
  orange: {
    bg: 'bg-orange-50',
    icon: 'bg-orange-100 text-orange-700',
    value: 'text-orange-700',
  },
  purple: {
    bg: 'bg-purple-50',
    icon: 'bg-purple-100 text-purple-700',
    value: 'text-purple-700',
  },
  slate: {
    bg: 'bg-slate-50',
    icon: 'bg-slate-100 text-slate-700',
    value: 'text-slate-700',
  },
}
