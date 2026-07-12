export const INVOICE_STATUSES = [
  { value: 'DRAFT', label: 'Brouillon' },
  { value: 'ISSUED', label: 'Émise' },
  { value: 'PARTIALLY_PAID', label: 'Part. payée' },
  { value: 'PAID', label: 'Payée' },
  { value: 'CANCELLED', label: 'Annulée' },
]

export const INVOICE_STATUS_COLORS = {
  DRAFT: 'bg-gray-100 text-gray-600',
  ISSUED: 'bg-blue-100 text-blue-700',
  PARTIALLY_PAID: 'bg-orange-100 text-orange-700',
  PAID: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-600',
}

export const ITEM_TYPES = [
  { value: 'CONSULTATION', label: 'Consultation' },
  { value: 'HOSPITALIZATION', label: 'Nuitée' },
  { value: 'LAB', label: 'Examen labo' },
  { value: 'MEDICATION', label: 'Médicament' },
  { value: 'PROCEDURE', label: 'Acte médical' },
  { value: 'SUPPLY', label: 'Consommable' },
  { value: 'OTHER', label: 'Autre' },
]

export const PAYMENT_METHODS = [
  { value: 'CASH', label: 'Espèces' },
  { value: 'CARD', label: 'Carte bancaire' },
  { value: 'MOBILE', label: 'Mobile Money' },
  { value: 'INSURANCE', label: 'Assurance' },
  { value: 'BANK_TRANSFER', label: 'Virement' },
]

export const PAYMENT_METHOD_COLORS = {
  CASH: 'bg-green-100 text-green-700',
  CARD: 'bg-blue-100 text-blue-700',
  MOBILE: 'bg-purple-100 text-purple-700',
  INSURANCE: 'bg-teal-100 text-teal-700',
  BANK_TRANSFER: 'bg-indigo-100 text-indigo-700',
}

export function formatMoney(v) {
  if (v === null || v === undefined) return '–'
  return `${parseFloat(v).toLocaleString('fr-FR', { minimumFractionDigits: 0, maximumFractionDigits: 2 })} F`
}

export function itemTotal(item) {
  const qty = parseInt(item.quantity) || 0
  const price = parseFloat(item.unit_price) || 0
  const disc = parseFloat(item.discount_percent) || 0
  return qty * price * (1 - disc / 100)
}
