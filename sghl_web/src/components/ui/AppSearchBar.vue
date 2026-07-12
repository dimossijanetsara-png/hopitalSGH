<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  placeholder: { type: String, default: 'Rechercher…' },
  debounce: { type: Number, default: 350 },
})
const emit = defineEmits(['update:modelValue'])

const local = ref(props.modelValue)
let timer

watch(local, (val) => {
  clearTimeout(timer)
  timer = setTimeout(() => emit('update:modelValue', val), props.debounce)
})

watch(() => props.modelValue, (v) => { if (v !== local.value) local.value = v })
</script>

<template>
  <div class="relative">
    <svg
      class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
      fill="none" stroke="currentColor" viewBox="0 0 24 24"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
    </svg>
    <input
      v-model="local"
      type="text"
      :placeholder="placeholder"
      class="w-full pl-9 pr-4 py-2 text-sm rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:border-blue-400"
    />
    <button
      v-if="local"
      @click="local = ''"
      class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
    >
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
  </div>
</template>
