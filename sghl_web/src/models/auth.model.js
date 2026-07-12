export const ROLES = {
  ADMIN: 'ADMIN',
  DOCTOR: 'DOCTOR',
  NURSE: 'NURSE',
  BIOLOGIST: 'BIOLOGIST',
  PHARMACIST: 'PHARMACIST',
  RECEPTIONIST: 'RECEPTIONIST',
  ACCOUNTANT: 'ACCOUNTANT',
  PATIENT: 'PATIENT',
  LABTECH: 'LABTECH',
  OTHER: 'OTHER',
}

export const ROLE_LABELS = {
  ADMIN: 'Superutilisateur',
  DOCTOR: 'Médecin',
  NURSE: 'Infirmier(e)',
  BIOLOGIST: 'Biologiste',
  PHARMACIST: 'Pharmacien(ne)',
  RECEPTIONIST: 'Secrétaire',
  ACCOUNTANT: 'Comptable',
  PATIENT: 'Patient',
  LABTECH: 'Technicien labo',
  OTHER: 'Autre personnel',
}

export const ROLE_COLORS = {
  ADMIN: 'bg-violet-100 text-violet-800',
  DOCTOR: 'bg-blue-100 text-blue-800',
  NURSE: 'bg-teal-100 text-teal-800',
  BIOLOGIST: 'bg-emerald-100 text-emerald-800',
  PHARMACIST: 'bg-orange-100 text-orange-800',
  RECEPTIONIST: 'bg-indigo-100 text-indigo-800',
  ACCOUNTANT: 'bg-amber-100 text-amber-800',
  PATIENT: 'bg-pink-100 text-pink-800',
  LABTECH: 'bg-cyan-100 text-cyan-800',
  OTHER: 'bg-gray-100 text-gray-700',
}

// Gradient pour la sidebar (bande colorée du rôle)
export const ROLE_GRADIENT = {
  ADMIN: 'from-violet-600 to-purple-700',
  DOCTOR: 'from-blue-600 to-blue-700',
  NURSE: 'from-teal-500 to-teal-600',
  BIOLOGIST: 'from-emerald-500 to-emerald-600',
  PHARMACIST: 'from-orange-500 to-orange-600',
  RECEPTIONIST: 'from-indigo-500 to-indigo-600',
  ACCOUNTANT: 'from-amber-500 to-amber-600',
  PATIENT: 'from-pink-500 to-pink-600',
  LABTECH: 'from-cyan-500 to-cyan-600',
  OTHER: 'from-gray-500 to-gray-600',
}

// Carte de sélection du rôle à l'inscription
export const ROLE_CARDS = [
  {
    value: 'DOCTOR',
    label: 'Médecin',
    description: 'Consultation, prescriptions, hospitalisations',
    gradient: 'from-blue-500 to-blue-700',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01',
  },
  {
    value: 'NURSE',
    label: 'Infirmier(e)',
    description: 'Soins infirmiers, suivi des patients',
    gradient: 'from-teal-500 to-teal-700',
    icon: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z',
  },
  {
    value: 'PATIENT',
    label: 'Patient',
    description: 'Rendez-vous, consultations, résultats',
    gradient: 'from-pink-500 to-pink-700',
    icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z',
  },
  {
    value: 'RECEPTIONIST',
    label: 'Secrétaire',
    description: 'Accueil, admissions, rendez-vous',
    gradient: 'from-indigo-500 to-indigo-700',
    icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
  {
    value: 'BIOLOGIST',
    label: 'Biologiste',
    description: 'Analyses biologiques, résultats de labo',
    gradient: 'from-emerald-500 to-emerald-700',
    icon: 'M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z',
  },
  {
    value: 'ACCOUNTANT',
    label: 'Comptable',
    description: 'Facturation, paiements, finances',
    gradient: 'from-amber-500 to-amber-700',
    icon: 'M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z',
  },
  {
    value: 'PHARMACIST',
    label: 'Pharmacien(ne)',
    description: 'Médicaments, stocks, dispensation',
    gradient: 'from-orange-500 to-orange-700',
    icon: 'M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z',
  },
  {
    value: 'LABTECH',
    label: 'Technicien labo',
    description: 'Prélèvements, traitement des échantillons',
    gradient: 'from-cyan-500 to-cyan-700',
    icon: 'M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z',
  },
  {
    value: 'OTHER',
    label: 'Autre personnel',
    description: 'Agent de sécurité, nettoyage, maintenance…',
    gradient: 'from-slate-500 to-slate-700',
    icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z',
  },
]

export const DASHBOARD_ROUTES_BY_ROLE = {
  ADMIN: '/dashboard',
  DOCTOR: '/dashboard',
  NURSE: '/soins',
  BIOLOGIST: '/laboratoire',
  PHARMACIST: '/pharmacie',
  RECEPTIONIST: '/patients',
  ACCOUNTANT: '/facturation',
  PATIENT: '/rendez-vous',
  LABTECH: '/laboratoire',
  OTHER: '/dashboard',
}
