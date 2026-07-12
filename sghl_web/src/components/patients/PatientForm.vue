<script setup>
import { ref, watch } from 'vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import { GENDERS, BLOOD_TYPES } from '@/models/patient.model'

const props = defineProps({
  initial: { type: Object, default: null },
  loading: { type: Boolean, default: false },
  error: { type: String, default: null },
  success: { type: Boolean, default: false },
})
const emit = defineEmits(['submit'])

const form = ref({
  first_name: '', last_name: '', date_of_birth: '', gender: 'M',
  national_id: '', phone: '', email: '', address: '', city: '',
  blood_type: 'INC', allergies: '', chronic_conditions: '',
  emergency_contact_name: '', emergency_contact_phone: '', emergency_contact_relation: '',
  insurance_provider: '', insurance_number: '',
})

watch(() => props.initial, (val) => {
  if (val) Object.assign(form.value, val)
}, { immediate: true })

function handleSubmit() {
  emit('submit', { ...form.value })
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <AppAlert v-if="error" type="error" :message="error" />
    <AppAlert v-if="success" type="success" message="Patient enregistré avec succès." />

    <!-- Identité -->
    <section>
      <h3 class="text-sm font-semibold text-gray-700 mb-3 pb-2 border-b border-gray-100">
        Identité
      </h3>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <AppInput v-model="form.first_name" label="Prénom" required />
        <AppInput v-model="form.last_name" label="Nom" required />
        <AppInput v-model="form.date_of_birth" label="Date de naissance" type="date" required />
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Sexe <span class="text-red-500">*</span></label>
          <select v-model="form.gender"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300">
            <option v-for="g in GENDERS" :key="g.value" :value="g.value">{{ g.label }}</option>
          </select>
        </div>
        <AppInput v-model="form.national_id" label="N° CNI / Passeport" />
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Groupe sanguin</label>
          <select v-model="form.blood_type"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300">
            <option v-for="bt in BLOOD_TYPES" :key="bt" :value="bt">{{ bt }}</option>
          </select>
        </div>
      </div>
    </section>

    <!-- Contact -->
    <section>
      <h3 class="text-sm font-semibold text-gray-700 mb-3 pb-2 border-b border-gray-100">
        Contact
      </h3>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <AppInput v-model="form.phone" label="Téléphone" type="tel" required />
        <AppInput v-model="form.email" label="E-mail" type="email" />
        <AppInput v-model="form.address" label="Adresse" />
        <AppInput v-model="form.city" label="Ville" />
      </div>
    </section>

    <!-- Médical -->
    <section>
      <h3 class="text-sm font-semibold text-gray-700 mb-3 pb-2 border-b border-gray-100">
        Informations médicales
      </h3>
      <div class="grid grid-cols-1 gap-4">
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Allergies connues</label>
          <textarea v-model="form.allergies" rows="2"
            placeholder="Pénicilline, arachides…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-sm font-medium text-gray-700">Pathologies chroniques</label>
          <textarea v-model="form.chronic_conditions" rows="2"
            placeholder="Diabète, hypertension…"
            class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none" />
        </div>
      </div>
    </section>

    <!-- Contact urgence -->
    <section>
      <h3 class="text-sm font-semibold text-gray-700 mb-3 pb-2 border-b border-gray-100">
        Contact d'urgence
      </h3>
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <AppInput v-model="form.emergency_contact_name" label="Nom" />
        <AppInput v-model="form.emergency_contact_phone" label="Téléphone" type="tel" />
        <AppInput v-model="form.emergency_contact_relation" label="Lien (ex. Époux/se)" />
      </div>
    </section>

    <!-- Assurance -->
    <section>
      <h3 class="text-sm font-semibold text-gray-700 mb-3 pb-2 border-b border-gray-100">
        Assurance
      </h3>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <AppInput v-model="form.insurance_provider" label="Organisme assureur" />
        <AppInput v-model="form.insurance_number" label="N° de police" />
      </div>
    </section>

    <div class="flex justify-end gap-3 pt-2">
      <slot name="actions" />
      <AppButton type="submit" :loading="loading">
        {{ initial ? 'Enregistrer les modifications' : 'Créer le patient' }}
      </AppButton>
    </div>
  </form>
</template>
