<script setup>
import { ref } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import AppModal from '@/components/ui/AppModal.vue'
import AppInput from '@/components/ui/AppInput.vue'
import AppAlert from '@/components/ui/AppAlert.vue'
import BedMap from './BedMap.vue'
import { ROOM_TYPES, ROOM_TYPE_COLORS } from '@/models/hospitalisation.model'
import {
  useBuildings, useCreateBuilding,
  useDepartments, useCreateDepartment,
  useRooms, useCreateRoom,
  useBeds, useCreateBed,
} from '@/controllers/useHospitalisation'

// ─── State ────────────────────────────────────────────────────────────────────
const selectedBuildingId = ref(null)
const selectedDepartmentId = ref(null)
const selectedRoomId = ref(null)

const { buildings, loading: loadingBuildings } = useBuildings()
const { departments, loading: loadingDepts } = useDepartments(selectedBuildingId)
const { rooms, loading: loadingRooms } = useRooms(selectedDepartmentId)
const { beds, loading: loadingBeds } = useBeds(selectedRoomId)

// ─── Create modals ────────────────────────────────────────────────────────────
const showBuildingModal = ref(false)
const showDeptModal = ref(false)
const showRoomModal = ref(false)
const showBedModal = ref(false)

const buildingForm = ref({ name: '', address: '' })
const deptForm = ref({ name: '', building: '' })
const roomForm = ref({ number: '', floor: '', type: 'STANDARD', department: '', capacity: 1 })
const bedForm = ref({ number: '', room: '' })

const { submit: createBuilding, loading: savingBuilding, error: buildingError } = useCreateBuilding()
const { submit: createDept, loading: savingDept, error: deptError } = useCreateDepartment()
const { submit: createRoom, loading: savingRoom, error: roomError } = useCreateRoom()
const { submit: createBed, loading: savingBed, error: bedError } = useCreateBed()

function openDeptModal() {
  deptForm.value = { name: '', building: selectedBuildingId.value || '' }
  showDeptModal.value = true
}
function openRoomModal() {
  roomForm.value = { number: '', floor: '', type: 'STANDARD', department: selectedDepartmentId.value || '', capacity: 1 }
  showRoomModal.value = true
}
function openBedModal() {
  bedForm.value = { number: '', room: selectedRoomId.value || '' }
  showBedModal.value = true
}
</script>

<template>
  <div class="space-y-6">
    <!-- Buildings -->
    <div class="bg-white rounded-xl border border-gray-200 p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-gray-800">Bâtiments</h3>
        <AppButton size="sm" @click="showBuildingModal = true">+ Bâtiment</AppButton>
      </div>
      <div v-if="loadingBuildings" class="flex justify-center py-4"><AppSpinner /></div>
      <div v-else-if="!buildings?.results?.length && !buildings?.length" class="text-sm text-gray-400 py-2">
        Aucun bâtiment
      </div>
      <div v-else class="flex flex-wrap gap-2">
        <button
          v-for="b in (buildings?.results || buildings || [])"
          :key="b.id"
          :class="[
            'px-3 py-1.5 rounded-lg text-sm border transition-colors',
            selectedBuildingId === b.id
              ? 'bg-blue-600 text-white border-blue-600'
              : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300',
          ]"
          @click="selectedBuildingId = b.id; selectedDepartmentId = null; selectedRoomId = null"
        >
          {{ b.name }}
        </button>
      </div>
    </div>

    <!-- Departments -->
    <div v-if="selectedBuildingId" class="bg-white rounded-xl border border-gray-200 p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-gray-800">Services</h3>
        <AppButton size="sm" @click="openDeptModal">+ Service</AppButton>
      </div>
      <div v-if="loadingDepts" class="flex justify-center py-4"><AppSpinner /></div>
      <div v-else-if="!departments?.results?.length && !departments?.length" class="text-sm text-gray-400 py-2">
        Aucun service dans ce bâtiment
      </div>
      <div v-else class="flex flex-wrap gap-2">
        <button
          v-for="d in (departments?.results || departments || [])"
          :key="d.id"
          :class="[
            'px-3 py-1.5 rounded-lg text-sm border transition-colors',
            selectedDepartmentId === d.id
              ? 'bg-blue-600 text-white border-blue-600'
              : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300',
          ]"
          @click="selectedDepartmentId = d.id; selectedRoomId = null"
        >
          {{ d.name }}
        </button>
      </div>
    </div>

    <!-- Rooms -->
    <div v-if="selectedDepartmentId" class="bg-white rounded-xl border border-gray-200 p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-gray-800">Chambres</h3>
        <AppButton size="sm" @click="openRoomModal">+ Chambre</AppButton>
      </div>
      <div v-if="loadingRooms" class="flex justify-center py-4"><AppSpinner /></div>
      <div v-else-if="!rooms?.results?.length && !rooms?.length" class="text-sm text-gray-400 py-2">
        Aucune chambre dans ce service
      </div>
      <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
        <button
          v-for="r in (rooms?.results || rooms || [])"
          :key="r.id"
          :class="[
            'p-3 rounded-lg border-2 text-left transition-all',
            selectedRoomId === r.id ? 'border-blue-500 bg-blue-50' : 'border-gray-200 bg-white hover:border-blue-200',
          ]"
          @click="selectedRoomId = r.id"
        >
          <p class="font-medium text-sm text-gray-800">Chambre {{ r.number }}</p>
          <p class="text-xs text-gray-500">Étage {{ r.floor || '–' }}</p>
          <span :class="['inline-block mt-1 text-xs px-1.5 py-0.5 rounded', ROOM_TYPE_COLORS[r.type] || 'bg-gray-100 text-gray-600']">
            {{ ROOM_TYPES.find(t => t.value === r.type)?.label || r.type }}
          </span>
        </button>
      </div>
    </div>

    <!-- Bed map -->
    <div v-if="selectedRoomId" class="bg-white rounded-xl border border-gray-200 p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-gray-800">Lits</h3>
        <AppButton size="sm" @click="openBedModal">+ Lit</AppButton>
      </div>
      <BedMap :beds="beds?.results || beds || []" :loading="loadingBeds" />
    </div>
  </div>

  <!-- Building modal -->
  <AppModal :open="showBuildingModal" title="Nouveau bâtiment" size="sm" @close="showBuildingModal = false">
    <form @submit.prevent="createBuilding(buildingForm, { onSuccess: () => { showBuildingModal = false } })" class="space-y-4">
      <AppAlert v-if="buildingError" type="error" :message="buildingError" />
      <AppInput v-model="buildingForm.name" label="Nom" required />
      <AppInput v-model="buildingForm.address" label="Adresse" />
    </form>
    <template #footer>
      <AppButton variant="secondary" @click="showBuildingModal = false">Annuler</AppButton>
      <AppButton :loading="savingBuilding" @click="createBuilding(buildingForm, { onSuccess: () => { showBuildingModal = false } })">
        Créer
      </AppButton>
    </template>
  </AppModal>

  <!-- Department modal -->
  <AppModal :open="showDeptModal" title="Nouveau service" size="sm" @close="showDeptModal = false">
    <form @submit.prevent="createDept(deptForm, { onSuccess: () => { showDeptModal = false } })" class="space-y-4">
      <AppAlert v-if="deptError" type="error" :message="deptError" />
      <AppInput v-model="deptForm.name" label="Nom du service" required />
      <AppInput v-model="deptForm.building" label="ID Bâtiment" required />
    </form>
    <template #footer>
      <AppButton variant="secondary" @click="showDeptModal = false">Annuler</AppButton>
      <AppButton :loading="savingDept" @click="createDept(deptForm, { onSuccess: () => { showDeptModal = false } })">
        Créer
      </AppButton>
    </template>
  </AppModal>

  <!-- Room modal -->
  <AppModal :open="showRoomModal" title="Nouvelle chambre" size="sm" @close="showRoomModal = false">
    <form @submit.prevent="createRoom(roomForm, { onSuccess: () => { showRoomModal = false } })" class="space-y-4">
      <AppAlert v-if="roomError" type="error" :message="roomError" />
      <div class="grid grid-cols-2 gap-3">
        <AppInput v-model="roomForm.number" label="Numéro" required />
        <AppInput v-model="roomForm.floor" label="Étage" />
      </div>
      <div>
        <label class="text-sm font-medium text-gray-700 block mb-1">Type</label>
        <select v-model="roomForm.type" class="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300">
          <option v-for="t in ROOM_TYPES" :key="t.value" :value="t.value">{{ t.label }}</option>
        </select>
      </div>
      <AppInput v-model="roomForm.department" label="ID Service" required />
      <AppInput v-model="roomForm.capacity" label="Capacité (lits)" type="number" />
    </form>
    <template #footer>
      <AppButton variant="secondary" @click="showRoomModal = false">Annuler</AppButton>
      <AppButton :loading="savingRoom" @click="createRoom(roomForm, { onSuccess: () => { showRoomModal = false } })">
        Créer
      </AppButton>
    </template>
  </AppModal>

  <!-- Bed modal -->
  <AppModal :open="showBedModal" title="Nouveau lit" size="sm" @close="showBedModal = false">
    <form @submit.prevent="createBed(bedForm, { onSuccess: () => { showBedModal = false } })" class="space-y-4">
      <AppAlert v-if="bedError" type="error" :message="bedError" />
      <AppInput v-model="bedForm.number" label="Numéro / Identifiant" required />
      <AppInput v-model="bedForm.room" label="ID Chambre" required />
    </form>
    <template #footer>
      <AppButton variant="secondary" @click="showBedModal = false">Annuler</AppButton>
      <AppButton :loading="savingBed" @click="createBed(bedForm, { onSuccess: () => { showBedModal = false } })">
        Créer
      </AppButton>
    </template>
  </AppModal>
</template>
