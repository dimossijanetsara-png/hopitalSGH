export const CONSULTATION_STATUSES = [
  { value: 'SCHEDULED', label: 'Planifiée' },
  { value: 'IN_PROGRESS', label: 'En cours' },
  { value: 'COMPLETED', label: 'Terminée' },
  { value: 'CANCELLED', label: 'Annulée' },
]

export const CONSULTATION_STATUS_COLORS = {
  SCHEDULED: 'bg-blue-100 text-blue-700',
  IN_PROGRESS: 'bg-yellow-100 text-yellow-700',
  COMPLETED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-gray-100 text-gray-500',
}

export const DIAG_TYPES = [
  { value: 'PRINCIPAL', label: 'Principal' },
  { value: 'SECONDARY', label: 'Secondaire' },
  { value: 'DIFFERENTIAL', label: 'Différentiel' },
]

export const DIAG_TYPE_COLORS = {
  PRINCIPAL: 'bg-red-100 text-red-700',
  SECONDARY: 'bg-orange-100 text-orange-700',
  DIFFERENTIAL: 'bg-blue-100 text-blue-700',
}

export const PRESCRIPTION_STATUSES = [
  { value: 'DRAFT', label: 'Brouillon' },
  { value: 'VALIDATED', label: 'Validée' },
  { value: 'DISPENSED', label: 'Dispensée' },
  { value: 'CANCELLED', label: 'Annulée' },
]

export const PRESCRIPTION_STATUS_COLORS = {
  DRAFT: 'bg-gray-100 text-gray-600',
  VALIDATED: 'bg-green-100 text-green-700',
  DISPENSED: 'bg-blue-100 text-blue-700',
  CANCELLED: 'bg-red-100 text-red-500',
}

export const PRESCRIPTION_FREQUENCIES = [
  { value: '1x/jour', label: '1 fois par jour' },
  { value: '2x/jour', label: '2 fois par jour' },
  { value: '3x/jour', label: '3 fois par jour' },
  { value: '4x/jour', label: '4 fois par jour' },
  { value: 'Matin', label: 'Matin seulement' },
  { value: 'Soir', label: 'Soir seulement' },
  { value: 'Si besoin', label: 'Si besoin (PRN)' },
]

export const PRESCRIPTION_ROUTES = [
  { value: 'PO', label: 'Per os (oral)' },
  { value: 'IV', label: 'Intraveineux' },
  { value: 'IM', label: 'Intramusculaire' },
  { value: 'SC', label: 'Sous-cutané' },
  { value: 'TOPIQUE', label: 'Topique' },
  { value: 'INHALATION', label: 'Inhalation' },
  { value: 'AUTRE', label: 'Autre' },
]

// Quelques codes CIM-10 courants pour suggestion rapide
export const COMMON_ICD10 = [
  { code: 'J06.9', label: 'Infection aiguë des voies respiratoires supérieures, sans précision' },
  { code: 'I10', label: 'Hypertension essentielle (primaire)' },
  { code: 'E11', label: 'Diabète sucré de type 2' },
  { code: 'K21.0', label: 'Maladie de reflux gastro-œsophagien avec œsophagite' },
  { code: 'M54.5', label: 'Lombalgie basse' },
  { code: 'J18.9', label: 'Pneumonie, sans précision' },
  { code: 'A09', label: 'Diarrhée et gastro-entérite' },
  { code: 'R51', label: 'Céphalée' },
  { code: 'Z23', label: 'Vaccination' },
  { code: 'B34.9', label: 'Infection virale, sans précision' },
]
