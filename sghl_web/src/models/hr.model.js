export const SHIFT_TYPES = [
  { value: 'MORNING', label: 'Matin' },
  { value: 'AFTERNOON', label: 'Après-midi' },
  { value: 'NIGHT', label: 'Nuit' },
  { value: 'ON_CALL', label: 'De garde' },
]

export const SHIFT_TYPE_COLORS = {
  MORNING: 'bg-yellow-100 text-yellow-700',
  AFTERNOON: 'bg-orange-100 text-orange-700',
  NIGHT: 'bg-indigo-100 text-indigo-700',
  ON_CALL: 'bg-red-100 text-red-700',
}

export const SHIFT_TYPE_BG = {
  MORNING: 'border-yellow-300 bg-yellow-50',
  AFTERNOON: 'border-orange-300 bg-orange-50',
  NIGHT: 'border-indigo-300 bg-indigo-50',
  ON_CALL: 'border-red-300 bg-red-50',
}
