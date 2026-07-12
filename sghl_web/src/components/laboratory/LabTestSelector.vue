<script setup>
import { ref, computed } from 'vue'
import AppSpinner from '@/components/ui/AppSpinner.vue'
import { useLabTests } from '@/controllers/useLaboratory'

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
})
const emit = defineEmits(['update:modelValue'])

const { tests, loading } = useLabTests()
const search = ref('')
const activeCategory = ref('')

const categories = computed(() => {
  if (!tests.value) return []
  const list = tests.value?.results || tests.value || []
  return [...new Set(list.map((t) => t.category))].sort()
})

const filtered = computed(() => {
  const list = tests.value?.results || tests.value || []
  return list.filter((t) => {
    const matchCat = !activeCategory.value || t.category === activeCategory.value
    const matchSearch =
      !search.value ||
      t.name.toLowerCase().includes(search.value.toLowerCase()) ||
      t.code.toLowerCase().includes(search.value.toLowerCase())
    return matchCat && matchSearch
  })
})

function toggle(testId) {
  const current = [...props.modelValue]
  const idx = current.indexOf(testId)
  if (idx === -1) current.push(testId)
  else current.splice(idx, 1)
  emit('update:modelValue', current)
}

function isSelected(testId) {
  return props.modelValue.includes(testId)
}

const totalPrice = computed(() => {
  const list = tests.value?.results || tests.value || []
  return props.modelValue.reduce((sum, id) => {
    const t = list.find((x) => x.id === id)
    return sum + (t ? parseFloat(t.price) : 0)
  }, 0)
})
</script>

<template>
  <div>
    <!-- Search & filter -->
    <div class="flex gap-2 mb-3">
      <input
        v-model="search"
        type="text"
        placeholder="Rechercher une analyse…"
        class="flex-1 px-3 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300"
      />
    </div>

    <!-- Category pills -->
    <div class="flex flex-wrap gap-1.5 mb-3">
      <button
        :class="[
          'px-2.5 py-1 rounded-full text-xs font-medium transition-colors',
          !activeCategory ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200',
        ]"
        @click="activeCategory = ''"
      >
        Tous
      </button>
      <button
        v-for="cat in categories"
        :key="cat"
        :class="[
          'px-2.5 py-1 rounded-full text-xs font-medium transition-colors',
          activeCategory === cat ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200',
        ]"
        @click="activeCategory = cat"
      >
        {{ cat }}
      </button>
    </div>

    <!-- List -->
    <div v-if="loading" class="flex justify-center py-6"><AppSpinner /></div>
    <div v-else-if="!filtered.length" class="text-center py-6 text-gray-400 text-sm">
      Aucune analyse trouvée
    </div>
    <div v-else class="space-y-1 max-h-64 overflow-y-auto pr-1">
      <label
        v-for="test in filtered"
        :key="test.id"
        :class="[
          'flex items-center justify-between gap-3 px-3 py-2.5 rounded-lg cursor-pointer border transition-colors',
          isSelected(test.id)
            ? 'border-blue-400 bg-blue-50'
            : 'border-gray-100 bg-white hover:border-gray-300',
        ]"
      >
        <div class="flex items-center gap-2.5 min-w-0">
          <input
            type="checkbox"
            :checked="isSelected(test.id)"
            class="rounded text-blue-600"
            @change="toggle(test.id)"
          />
          <div class="min-w-0">
            <p class="text-sm font-medium text-gray-800 truncate">{{ test.name }}</p>
            <p class="text-xs text-gray-400">{{ test.code }} · {{ test.category }}</p>
          </div>
        </div>
        <div class="text-right shrink-0">
          <p class="text-sm font-semibold text-gray-700">{{ parseFloat(test.price).toLocaleString('fr-FR') }} F</p>
          <p class="text-xs text-gray-400">{{ test.turnaround_hours }}h</p>
        </div>
      </label>
    </div>

    <!-- Summary -->
    <div v-if="modelValue.length" class="mt-3 flex items-center justify-between text-sm bg-blue-50 rounded-lg px-3 py-2">
      <span class="text-blue-700 font-medium">{{ modelValue.length }} analyse(s) sélectionnée(s)</span>
      <span class="text-blue-800 font-bold">{{ totalPrice.toLocaleString('fr-FR') }} F</span>
    </div>
  </div>
</template>
