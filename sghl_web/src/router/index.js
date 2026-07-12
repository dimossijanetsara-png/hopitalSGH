import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth.store'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    // Auth
    {
      path: '/connexion',
      name: 'login',
      component: () => import('@/views/auth/LoginView.vue'),
      meta: { public: true },
    },
    {
      path: '/mfa',
      name: 'mfa',
      component: () => import('@/views/auth/MFAView.vue'),
      meta: { public: true },
    },
    {
      path: '/inscription',
      name: 'register',
      component: () => import('@/views/auth/RegisterView.vue'),
      meta: { public: true },
    },
    {
      path: '/configuration-initiale',
      name: 'setup-admin',
      component: () => import('@/views/auth/SetupAdminView.vue'),
      meta: { public: true },
    },

    // Profil
    {
      path: '/profil',
      name: 'profile',
      component: () => import('@/views/auth/ProfileView.vue'),
    },
    {
      path: '/changer-mot-de-passe',
      name: 'change-password',
      component: () => import('@/views/auth/ChangePasswordView.vue'),
    },
    {
      path: '/configurer-mfa',
      name: 'setup-mfa',
      component: () => import('@/views/auth/SetupMFAView.vue'),
    },
    {
      path: '/utilisateurs',
      name: 'users',
      component: () => import('@/views/auth/UsersView.vue'),
    },

    // Dashboard (placeholder pour les modules suivants)
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/dashboard/DashboardView.vue'),
    },
    {
      path: '/patients',
      name: 'patients',
      component: () => import('@/views/patients/PatientsView.vue'),
    },
    {
      path: '/patients/nouveau',
      name: 'patient-create',
      component: () => import('@/views/patients/PatientFormView.vue'),
    },
    {
      path: '/patients/:id',
      name: 'patient-detail',
      component: () => import('@/views/patients/PatientDetailView.vue'),
    },
    {
      path: '/patients/:id/modifier',
      name: 'patient-edit',
      component: () => import('@/views/patients/PatientFormView.vue'),
    },
    {
      path: '/consultations',
      name: 'consultations',
      component: () => import('@/views/clinical/ConsultationsView.vue'),
    },
    {
      path: '/consultations/nouvelle',
      name: 'consultation-create',
      component: () => import('@/views/clinical/ConsultationFormView.vue'),
    },
    {
      path: '/consultations/:id',
      name: 'consultation-detail',
      component: () => import('@/views/clinical/ConsultationDetailView.vue'),
    },
    {
      path: '/hospitalisation',
      name: 'hospitalisation',
      component: () => import('@/views/hospitalisation/HospitalisationView.vue'),
    },
    {
      path: '/hospitalisation/admissions/nouvelle',
      name: 'admission-create',
      component: () => import('@/views/hospitalisation/AdmissionFormView.vue'),
    },
    {
      path: '/hospitalisation/admissions/:id',
      name: 'admission-detail',
      component: () => import('@/views/hospitalisation/AdmissionDetailView.vue'),
    },
    {
      path: '/soins',
      name: 'soins',
      component: () => import('@/views/nursing/SoinsView.vue'),
    },
    {
      path: '/laboratoire',
      name: 'laboratoire',
      component: () => import('@/views/laboratory/LaboratoireView.vue'),
    },
    {
      path: '/laboratoire/commandes/:id',
      name: 'lab-order-detail',
      component: () => import('@/views/laboratory/LabOrderDetailView.vue'),
    },
    {
      path: '/pharmacie',
      name: 'pharmacie',
      component: () => import('@/views/pharmacy/PharmacieView.vue'),
    },
    {
      path: '/pharmacie/medicaments/:id',
      name: 'medication-detail',
      component: () => import('@/views/pharmacy/MedicationDetailView.vue'),
    },
    {
      path: '/facturation',
      name: 'facturation',
      component: () => import('@/views/billing/FacturationView.vue'),
    },
    {
      path: '/facturation/factures/:id',
      name: 'invoice-detail',
      component: () => import('@/views/billing/InvoiceDetailView.vue'),
    },
    {
      path: '/rendez-vous',
      name: 'rendez-vous',
      component: () => import('@/views/appointments/RendezVousView.vue'),
    },
    {
      path: '/rh',
      name: 'rh',
      component: () => import('@/views/hr/RHView.vue'),
    },
    {
      path: '/messages',
      name: 'messages',
      component: () => import('@/views/messaging/MessagesView.vue'),
    },
    {
      path: '/medecins',
      name: 'medecins',
      component: () => import('@/views/auth/MedecinsView.vue'),
    },
    {
      path: '/export',
      name: 'export',
      component: () => import('@/views/export/ExportView.vue'),
    },

    // Redirect
    { path: '/', redirect: '/connexion' },
    { path: '/:pathMatch(.*)*', redirect: '/connexion' },
  ],
})

// Navigation guard
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.public) return true
  if (!auth.isAuthenticated) return { name: 'login' }
  return true
})

export default router
