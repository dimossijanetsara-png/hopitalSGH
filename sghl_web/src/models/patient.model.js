export const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'INC']

export const GENDERS = [
  { value: 'M', label: 'Masculin' },
  { value: 'F', label: 'Féminin' },
  { value: 'O', label: 'Autre' },
]

export const GENDER_LABELS = { M: 'Masculin', F: 'Féminin', O: 'Autre' }

export const DOC_TYPES = [
  { value: 'IDENTITY', label: "Pièce d'identité" },
  { value: 'INSURANCE', label: 'Assurance' },
  { value: 'MEDICAL_REPORT', label: 'Compte-rendu médical' },
  { value: 'IMAGING', label: 'Imagerie' },
  { value: 'OTHER', label: 'Autre' },
]

export const DOC_TYPE_LABELS = {
  IDENTITY: "Pièce d'identité",
  INSURANCE: 'Assurance',
  MEDICAL_REPORT: 'Compte-rendu',
  IMAGING: 'Imagerie',
  OTHER: 'Autre',
}

export const DOC_TYPE_COLORS = {
  IDENTITY: 'bg-blue-100 text-blue-700',
  INSURANCE: 'bg-green-100 text-green-700',
  MEDICAL_REPORT: 'bg-purple-100 text-purple-700',
  IMAGING: 'bg-orange-100 text-orange-700',
  OTHER: 'bg-gray-100 text-gray-600',
}

export const BLOOD_TYPE_COLORS = {
  'A+': 'bg-red-100 text-red-700',
  'A-': 'bg-red-100 text-red-700',
  'B+': 'bg-orange-100 text-orange-700',
  'B-': 'bg-orange-100 text-orange-700',
  'AB+': 'bg-purple-100 text-purple-700',
  'AB-': 'bg-purple-100 text-purple-700',
  'O+': 'bg-blue-100 text-blue-700',
  'O-': 'bg-blue-100 text-blue-700',
  INC: 'bg-gray-100 text-gray-600',
}

export function patientAge(dateOfBirth) {
  if (!dateOfBirth) return '—'
  const diff = Date.now() - new Date(dateOfBirth).getTime()
  return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25)) + ' ans'
}

export function formatDate(d) {
  if (!d) return '—'
  return new Intl.DateTimeFormat('fr-FR').format(new Date(d))
}
