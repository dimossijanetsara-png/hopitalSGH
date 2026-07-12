export const APPOINTMENT_STATUSES = [
  { value: 'PENDING', label: 'En attente' },
  { value: 'CONFIRMED', label: 'Confirmé' },
  { value: 'CANCELLED', label: 'Annulé' },
  { value: 'COMPLETED', label: 'Terminé' },
  { value: 'NO_SHOW', label: 'Absent' },
]

export const APPOINTMENT_STATUS_COLORS = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  CONFIRMED: 'bg-blue-100 text-blue-700',
  CANCELLED: 'bg-red-100 text-red-600',
  COMPLETED: 'bg-green-100 text-green-700',
  NO_SHOW: 'bg-gray-100 text-gray-500',
}

export const DAYS_OF_WEEK = [
  { value: 0, label: 'Lundi' },
  { value: 1, label: 'Mardi' },
  { value: 2, label: 'Mercredi' },
  { value: 3, label: 'Jeudi' },
  { value: 4, label: 'Vendredi' },
  { value: 5, label: 'Samedi' },
  { value: 6, label: 'Dimanche' },
]

export const NEXT_STATUSES = {
  PENDING: ['CONFIRMED', 'CANCELLED'],
  CONFIRMED: ['COMPLETED', 'CANCELLED', 'NO_SHOW'],
  CANCELLED: [],
  COMPLETED: [],
  NO_SHOW: [],
}
