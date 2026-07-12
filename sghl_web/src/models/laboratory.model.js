export const LAB_ORDER_STATUSES = [
  { value: 'ORDERED', label: 'Commande' },
  { value: 'SAMPLED', label: 'Prélevé' },
  { value: 'ASSIGNED', label: 'Affecté' },
  { value: 'IN_PROGRESS', label: 'En cours' },
  { value: 'RESULTED', label: 'Résultat saisi' },
  { value: 'VALIDATED', label: 'Validé' },
  { value: 'PUBLISHED', label: 'Publié' },
  { value: 'CANCELLED', label: 'Annulé' },
]

export const LAB_ORDER_STATUS_COLORS = {
  ORDERED: 'bg-gray-100 text-gray-600',
  SAMPLED: 'bg-blue-100 text-blue-700',
  ASSIGNED: 'bg-indigo-100 text-indigo-700',
  IN_PROGRESS: 'bg-yellow-100 text-yellow-700',
  RESULTED: 'bg-orange-100 text-orange-700',
  VALIDATED: 'bg-teal-100 text-teal-700',
  PUBLISHED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-600',
}

export const LAB_PRIORITIES = [
  { value: 'URGENT', label: 'Urgent' },
  { value: 'NORMAL', label: 'Normal' },
  { value: 'ROUTINE', label: 'Routine' },
]

export const LAB_PRIORITY_COLORS = {
  URGENT: 'bg-red-100 text-red-700',
  NORMAL: 'bg-blue-100 text-blue-700',
  ROUTINE: 'bg-gray-100 text-gray-600',
}

// Workflow transitions: which actions are available per status
export const LAB_WORKFLOW = {
  ORDERED: [{ action: 'sample', label: 'Marquer prélevé', variant: 'primary' }],
  SAMPLED: [{ action: 'assign', label: 'Affecter biologiste', variant: 'primary' }],
  ASSIGNED: [],
  IN_PROGRESS: [],
  RESULTED: [{ action: 'validate', label: 'Valider', variant: 'success' }],
  VALIDATED: [{ action: 'publish', label: 'Publier', variant: 'success' }],
  PUBLISHED: [],
  CANCELLED: [],
}
