export const TASK_FREQUENCIES = [
  { value: 'ONCE', label: 'Une seule fois' },
  { value: 'DAILY', label: 'Quotidien' },
  { value: 'BID', label: '2×/jour' },
  { value: 'TID', label: '3×/jour' },
  { value: 'QID', label: '4×/jour' },
  { value: 'PRN', label: 'Si besoin' },
]

export const TASK_STATUSES = [
  { value: 'PENDING', label: 'En attente' },
  { value: 'DONE', label: 'Effectuée' },
  { value: 'MISSED', label: 'Manquée' },
  { value: 'SKIPPED', label: 'Ignorée' },
]

export const TASK_STATUS_COLORS = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  DONE: 'bg-green-100 text-green-700',
  MISSED: 'bg-red-100 text-red-700',
  SKIPPED: 'bg-gray-100 text-gray-500',
}

export const PLAN_STATUSES = [
  { value: 'ACTIVE', label: 'Actif' },
  { value: 'COMPLETED', label: 'Terminé' },
  { value: 'CANCELLED', label: 'Annulé' },
]

export const PLAN_STATUS_COLORS = {
  ACTIVE: 'bg-green-100 text-green-700',
  COMPLETED: 'bg-blue-100 text-blue-700',
  CANCELLED: 'bg-gray-100 text-gray-500',
}

export const NOTE_CATEGORIES = [
  { value: '', label: 'Général' },
  { value: 'OBSERVATION', label: 'Observation' },
  { value: 'MEDICATION', label: 'Médicament' },
  { value: 'PROCEDURE', label: 'Procédure' },
  { value: 'ALERT', label: 'Alerte' },
]

export const NOTE_CATEGORY_COLORS = {
  '': 'bg-gray-100 text-gray-600',
  OBSERVATION: 'bg-blue-100 text-blue-700',
  MEDICATION: 'bg-purple-100 text-purple-700',
  PROCEDURE: 'bg-teal-100 text-teal-700',
  ALERT: 'bg-red-100 text-red-700',
}

export const VITAL_FIELDS = [
  { key: 'temperature', label: 'Température', unit: '°C', color: '#f97316', min: 35, max: 42 },
  { key: 'heart_rate', label: 'Fréq. cardiaque', unit: 'bpm', color: '#ef4444', min: 40, max: 200 },
  { key: 'systolic_bp', label: 'PA systolique', unit: 'mmHg', color: '#3b82f6', min: 60, max: 220 },
  { key: 'diastolic_bp', label: 'PA diastolique', unit: 'mmHg', color: '#6366f1', min: 40, max: 140 },
  { key: 'oxygen_saturation', label: 'SpO₂', unit: '%', color: '#06b6d4', min: 70, max: 100 },
  { key: 'respiratory_rate', label: 'Fréq. respiratoire', unit: '/min', color: '#10b981', min: 8, max: 40 },
  { key: 'pain_score', label: 'Douleur (EVA)', unit: '/10', color: '#f43f5e', min: 0, max: 10 },
]

export function vitalAlertLevel(key, value) {
  if (value === null || value === undefined) return null
  const v = parseFloat(value)
  if (key === 'temperature') {
    if (v < 36 || v > 38.5) return 'warning'
    if (v < 35 || v > 40) return 'danger'
  }
  if (key === 'heart_rate') {
    if (v < 60 || v > 100) return 'warning'
    if (v < 40 || v > 150) return 'danger'
  }
  if (key === 'oxygen_saturation') {
    if (v < 95) return 'warning'
    if (v < 90) return 'danger'
  }
  if (key === 'systolic_bp') {
    if (v > 140 || v < 90) return 'warning'
    if (v > 180 || v < 70) return 'danger'
  }
  return null
}
