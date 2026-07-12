export const ROOM_TYPES = [
  { value: 'STANDARD', label: 'Standard' },
  { value: 'PRIVATE', label: 'Privée' },
  { value: 'ICU', label: 'Réanimation (ICU)' },
  { value: 'EMERGENCY', label: 'Urgences' },
  { value: 'OPERATING', label: "Bloc opératoire" },
]

export const ROOM_TYPE_COLORS = {
  STANDARD: 'bg-gray-100 text-gray-700',
  PRIVATE: 'bg-blue-100 text-blue-700',
  ICU: 'bg-red-100 text-red-700',
  EMERGENCY: 'bg-orange-100 text-orange-700',
  OPERATING: 'bg-purple-100 text-purple-700',
}

export const BED_STATUSES = [
  { value: 'AVAILABLE', label: 'Disponible' },
  { value: 'OCCUPIED', label: 'Occupé' },
  { value: 'MAINTENANCE', label: 'Maintenance' },
  { value: 'RESERVED', label: 'Réservé' },
]

export const BED_STATUS_COLORS = {
  AVAILABLE: 'bg-green-100 text-green-700',
  OCCUPIED: 'bg-red-100 text-red-700',
  MAINTENANCE: 'bg-yellow-100 text-yellow-700',
  RESERVED: 'bg-blue-100 text-blue-700',
}

export const BED_STATUS_BG = {
  AVAILABLE: 'bg-green-100 border-green-300 text-green-800',
  OCCUPIED: 'bg-red-100 border-red-300 text-red-800',
  MAINTENANCE: 'bg-yellow-100 border-yellow-300 text-yellow-800',
  RESERVED: 'bg-blue-100 border-blue-300 text-blue-800',
}

export const HOSP_STATUSES = [
  { value: 'ACTIVE', label: 'Active' },
  { value: 'DISCHARGED', label: 'Sortie' },
  { value: 'TRANSFERRED', label: 'Transféré' },
  { value: 'DECEASED', label: 'Décédé' },
]

export const HOSP_STATUS_COLORS = {
  ACTIVE: 'bg-green-100 text-green-700',
  DISCHARGED: 'bg-gray-100 text-gray-600',
  TRANSFERRED: 'bg-blue-100 text-blue-700',
  DECEASED: 'bg-slate-100 text-slate-600',
}
