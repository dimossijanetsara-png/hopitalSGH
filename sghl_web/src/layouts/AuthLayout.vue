<script setup>
const features = [
  'Gestion des patients et dossiers médicaux',
  'Suivi des consultations et hospitalisations',
  'Laboratoire et résultats d\'analyses',
  'Facturation et ressources humaines',
]
</script>

<template>
  <div class="min-h-screen flex">
    <!-- ── Left branding panel (desktop only) ────────────────────────── -->
    <div class="hidden lg:flex w-[480px] xl:w-[540px] flex-col bg-linear-to-br from-blue-900 via-blue-800 to-teal-700 relative overflow-hidden shrink-0">
      <!-- Decorative blobs -->
      <div class="absolute -top-24 -right-24 w-80 h-80 rounded-full bg-white/5 pointer-events-none"></div>
      <div class="absolute -bottom-16 -left-16 w-64 h-64 rounded-full bg-white/5 pointer-events-none"></div>
      <div class="absolute top-1/3 right-1/4 w-48 h-48 rounded-full bg-teal-500/20 pointer-events-none"></div>
      <div class="absolute bottom-1/3 left-1/4 w-32 h-32 rounded-full bg-blue-400/20 pointer-events-none"></div>

      <!-- Center content -->
      <div class="relative z-10 flex flex-col items-center justify-center flex-1 px-12 text-center">
        <!-- Logo icon -->
        <div class="w-24 h-24 bg-white/10 backdrop-blur-sm border border-white/20 rounded-3xl flex items-center justify-center mb-8 shadow-2xl">
          <svg class="w-13 h-13 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" style="width:52px;height:52px">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
        </div>

        <h1 class="text-5xl font-extrabold text-white mb-2 tracking-tight">SGHL</h1>
        <p class="text-blue-200 text-lg font-medium mb-1">Système de Gestion</p>
        <p class="text-blue-200 text-lg font-medium mb-8">Hospitalière &amp; Laboratoire</p>

        <div class="flex items-center gap-3 mb-10">
          <div class="h-px w-12 bg-teal-400/60"></div>
          <div class="w-2 h-2 rounded-full bg-teal-400"></div>
          <div class="h-px w-12 bg-teal-400/60"></div>
        </div>

        <p class="text-blue-200/80 text-sm max-w-xs leading-relaxed mb-10">
          Plateforme intégrée de gestion hospitalière pour les équipes médicales et administratives.
        </p>

        <!-- Feature list -->
        <div class="space-y-3 text-left w-full max-w-xs">
          <div v-for="feat in features" :key="feat" class="flex items-center gap-3">
            <div class="w-5 h-5 rounded-full bg-teal-400/25 flex items-center justify-center shrink-0">
              <svg class="w-3 h-3 text-teal-300" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd"
                  d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                  clip-rule="evenodd" />
              </svg>
            </div>
            <span class="text-blue-100 text-sm">{{ feat }}</span>
          </div>
        </div>
      </div>

      <p class="relative z-10 text-center text-blue-300/50 text-xs pb-8">
        © {{ new Date().getFullYear() }} SGHL — Tous droits réservés
      </p>
    </div>

    <!-- ── Right form panel ───────────────────────────────────────────── -->
    <div class="flex-1 flex items-start justify-center overflow-y-auto bg-gray-50 min-h-screen">
      <div class="w-full max-w-md py-10 px-6 lg:px-8">
        <!-- Mobile logo -->
        <div class="flex items-center gap-3 mb-8 lg:hidden">
          <div class="w-10 h-10 bg-blue-700 rounded-xl flex items-center justify-center shadow">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </div>
          <div>
            <p class="font-bold text-gray-900 text-lg">SGHL</p>
            <p class="text-xs text-gray-500">Système de Gestion Hospitalière</p>
          </div>
        </div>

        <slot />
      </div>
    </div>
  </div>
</template>
