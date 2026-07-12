import { utils, writeFile } from 'xlsx'

/**
 * Export an array of data to an .xlsx file.
 * @param {Object[]} data - array of row objects
 * @param {Array<{header: string, key: string, format?: (v) => string}>} columns
 * @param {string} filename - without extension
 * @param {string} [sheetName]
 */
export function exportToExcel(data, columns, filename, sheetName = 'Données') {
  const rows = data.map((item) => {
    const row = {}
    columns.forEach((col) => {
      row[col.header] = col.format ? col.format(item[col.key], item) : (item[col.key] ?? '')
    })
    return row
  })

  const ws = utils.json_to_sheet(rows)

  // Auto column widths
  const colWidths = columns.map((col) => ({
    wch: Math.max(
      col.header.length,
      ...rows.map((r) => String(r[col.header] ?? '').length),
    ) + 2,
  }))
  ws['!cols'] = colWidths

  const wb = utils.book_new()
  utils.book_append_sheet(wb, ws, sheetName)
  writeFile(wb, `${filename}_${new Date().toISOString().slice(0, 10)}.xlsx`)
}

/**
 * Export multiple sheets to a single .xlsx file.
 * @param {Array<{name: string, data: Object[], columns: Object[]}>} sheets
 * @param {string} filename
 */
export function exportMultiSheet(sheets, filename) {
  const wb = utils.book_new()
  sheets.forEach(({ name, data, columns }) => {
    const rows = data.map((item) => {
      const row = {}
      columns.forEach((col) => {
        row[col.header] = col.format ? col.format(item[col.key], item) : (item[col.key] ?? '')
      })
      return row
    })
    const ws = utils.json_to_sheet(rows)
    ws['!cols'] = columns.map((col) => ({
      wch: Math.max(col.header.length, ...rows.map((r) => String(r[col.header] ?? '').length)) + 2,
    }))
    utils.book_append_sheet(wb, ws, name.slice(0, 31))
  })
  writeFile(wb, `${filename}_${new Date().toISOString().slice(0, 10)}.xlsx`)
}

// ─── Column definitions per module ───────────────────────────────────────────

export const PATIENT_COLUMNS = [
  { header: 'Nom', key: 'last_name' },
  { header: 'Prénom', key: 'first_name' },
  { header: 'Date de naissance', key: 'date_of_birth' },
  { header: 'Genre', key: 'gender' },
  { header: 'Email', key: 'email' },
  { header: 'Téléphone', key: 'phone' },
  { header: 'Groupe sanguin', key: 'blood_type' },
  { header: 'Adresse', key: 'address' },
]

export const APPOINTMENT_COLUMNS = [
  { header: 'Patient', key: 'patient', format: (v) => v?.full_name || v || '' },
  { header: 'Médecin', key: 'doctor', format: (v) => v?.full_name || v || '' },
  { header: 'Date', key: 'appointment_date', format: (v) => v ? new Date(v).toLocaleString('fr-FR') : '' },
  { header: 'Durée (min)', key: 'duration_minutes' },
  { header: 'Motif', key: 'reason' },
  { header: 'Statut', key: 'status' },
]

export const LAB_ORDER_COLUMNS = [
  { header: 'Patient', key: 'patient', format: (v) => v?.full_name || v || '' },
  { header: "Nb d'analyses", key: 'items', format: (v) => v?.length || 0 },
  { header: 'Priorité', key: 'priority' },
  { header: 'Statut', key: 'status' },
  { header: 'Date', key: 'created_at', format: (v) => v ? new Date(v).toLocaleDateString('fr-FR') : '' },
  { header: 'Notes', key: 'clinical_notes' },
]

export const INVOICE_COLUMNS = [
  { header: 'N° Facture', key: 'invoice_number' },
  { header: 'Patient', key: 'patient', format: (v) => v?.full_name || v || '' },
  { header: 'Total (F)', key: 'total' },
  { header: 'Payé (F)', key: 'amount_paid' },
  { header: 'Solde (F)', key: 'balance_due' },
  { header: 'Statut', key: 'status' },
  { header: 'Date', key: 'created_at', format: (v) => v ? new Date(v).toLocaleDateString('fr-FR') : '' },
]

export const HOSPITALIZATION_COLUMNS = [
  { header: 'Patient', key: 'patient', format: (v) => v?.full_name || v || '' },
  { header: 'Lit', key: 'bed', format: (v) => v?.number || v || '' },
  { header: 'Statut', key: 'status' },
  { header: 'Diagnostic', key: 'diagnosis' },
  { header: 'Admission', key: 'admission_date', format: (v) => v ? new Date(v).toLocaleDateString('fr-FR') : '' },
  { header: 'Sortie', key: 'discharge_date', format: (v) => v ? new Date(v).toLocaleDateString('fr-FR') : '' },
]

export const STAFF_COLUMNS = [
  { header: 'Nom', key: 'user', format: (v) => v ? `${v.last_name} ${v.first_name}` : '' },
  { header: 'Email', key: 'user', format: (v) => v?.email || '' },
  { header: 'Rôle', key: 'user', format: (v) => v?.role || '' },
  { header: 'Matricule', key: 'employee_number' },
  { header: 'Spécialisation', key: 'specialization' },
  { header: 'N° Licence', key: 'license_number' },
  { header: 'Date embauche', key: 'hire_date' },
  { header: 'Statut', key: 'is_active', format: (v) => v ? 'Actif' : 'Inactif' },
]
