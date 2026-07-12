<script setup>
defineProps({
  label: { type: String, default: '' },
  color: { type: String, default: 'bg-gray-100 text-gray-700' },
  dot: { type: Boolean, default: false },
})
</script>

<template>
  <span :class="['inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium', color]">
    <span v-if="dot" class="w-1.5 h-1.5 rounded-full bg-current opacity-70" />
    {{ label }}
  </span>
</template>
