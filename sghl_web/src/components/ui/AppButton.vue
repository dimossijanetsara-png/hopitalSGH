<script setup>
defineProps({
  type: { type: String, default: 'button' },
  variant: { type: String, default: 'primary' },
  loading: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  full: { type: Boolean, default: false },
  size: { type: String, default: 'md' },
})

const variants = {
  primary: 'bg-blue-700 hover:bg-blue-800 text-white focus:ring-blue-300',
  secondary: 'bg-gray-100 hover:bg-gray-200 text-gray-800 focus:ring-gray-200',
  danger: 'bg-red-600 hover:bg-red-700 text-white focus:ring-red-300',
  ghost: 'bg-transparent hover:bg-gray-100 text-gray-700 focus:ring-gray-200',
  success: 'bg-green-600 hover:bg-green-700 text-white focus:ring-green-300',
}

const sizes = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-sm',
  lg: 'px-6 py-3 text-base',
}
</script>

<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="[
      'inline-flex items-center justify-center gap-2 font-medium rounded-lg',
      'border border-transparent transition-colors duration-150',
      'focus:outline-none focus:ring-2 focus:ring-offset-1',
      'disabled:opacity-50 disabled:cursor-not-allowed',
      variants[variant],
      sizes[size],
      full ? 'w-full' : '',
    ]"
  >
    <svg
      v-if="loading"
      class="animate-spin h-4 w-4"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
      />
    </svg>
    <slot />
  </button>
</template>
