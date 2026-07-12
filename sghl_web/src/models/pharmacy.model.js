export const MOVEMENT_TYPES = [
  { value: 'IN', label: 'Entrée' },
  { value: 'OUT', label: 'Sortie' },
  { value: 'ADJUSTMENT', label: 'Ajustement' },
  { value: 'RETURN', label: 'Retour' },
  { value: 'EXPIRED', label: 'Périmé' },
]

export const MOVEMENT_TYPE_COLORS = {
  IN: 'bg-green-100 text-green-700',
  OUT: 'bg-red-100 text-red-700',
  ADJUSTMENT: 'bg-yellow-100 text-yellow-700',
  RETURN: 'bg-blue-100 text-blue-700',
  EXPIRED: 'bg-gray-100 text-gray-500',
}

export const DOSAGE_FORMS = [
  'Comprimé', 'Gélule', 'Sirop', 'Injection', 'Pommade',
  'Suppositoire', 'Sachet', 'Gouttes', 'Spray', 'Patch', 'Autre',
]

export function stockStatusClass(medication) {
  if (!medication) return ''
  if (medication.total_stock === 0) return 'text-red-700 font-bold'
  if (medication.is_low_stock) return 'text-orange-600 font-semibold'
  return 'text-green-700'
}

export function stockBadgeClass(medication) {
  if (!medication) return 'bg-gray-100 text-gray-500'
  if (medication.total_stock === 0) return 'bg-red-100 text-red-700'
  if (medication.is_low_stock) return 'bg-orange-100 text-orange-700'
  return 'bg-green-100 text-green-700'
}

export function stockLabel(medication) {
  if (!medication) return '–'
  if (medication.total_stock === 0) return 'Rupture'
  if (medication.is_low_stock) return 'Stock faible'
  return 'En stock'
}
