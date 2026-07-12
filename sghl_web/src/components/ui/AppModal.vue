<script setup>
defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, default: '' },
  size: { type: String, default: 'md' },
})
defineEmits(['close'])

const sizes = {
  sm: 'max-w-sm',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
}
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="open"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        @mousedown.self="$emit('close')"
      >
        <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" />
        <div
          :class="[
            'relative bg-white rounded-2xl shadow-2xl w-full',
            sizes[size],
            'max-h-[90vh] flex flex-col',
          ]"
        >
          <!-- Header -->
          <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200">
            <h3 class="text-base font-semibold text-gray-900">{{ title }}</h3>
            <button
              @click="$emit('close')"
              class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-400"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <!-- Body -->
          <div class="overflow-y-auto flex-1 px-6 py-4">
            <slot />
          </div>
          <!-- Footer -->
          <div v-if="$slots.footer" class="px-6 py-4 border-t border-gray-200 flex justify-end gap-3">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-enter-active, .modal-leave-active { transition: opacity 0.2s ease; }
.modal-enter-from, .modal-leave-to { opacity: 0; }
</style>
