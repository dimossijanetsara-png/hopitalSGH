<script setup>
import { computed } from 'vue'
import AppButton from '@/components/ui/AppButton.vue'
import { ITEM_TYPES, itemTotal, formatMoney } from '@/models/billing.model'

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
})
const emit = defineEmits(['update:modelValue'])

function addItem() {
  emit('update:modelValue', [
    ...props.modelValue,
    { item_type: 'CONSULTATION', description: '', quantity: 1, unit_price: '', discount_percent: 0, reference_id: '' },
  ])
}

function removeItem(i) {
  const items = [...props.modelValue]
  items.splice(i, 1)
  emit('update:modelValue', items)
}

function updateItem(i, field, value) {
  const items = props.modelValue.map((item, idx) =>
    idx === i ? { ...item, [field]: value } : item,
  )
  emit('update:modelValue', items)
}

const subtotal = computed(() =>
  props.modelValue.reduce((sum, item) => sum + itemTotal(item), 0),
)

function typeLabel(v) {
  return ITEM_TYPES.find((t) => t.value === v)?.label || v
}
</script>

<template>
  <div>
    <div class="space-y-3 mb-3">
      <div
        v-for="(item, i) in modelValue"
        :key="i"
        class="bg-gray-50 rounded-lg border border-gray-200 p-3 space-y-2"
      >
        <div class="flex items-center justify-between">
          <span class="text-xs font-semibold text-gray-500">Article {{ i + 1 }}</span>
          <button @click="removeItem(i)" class="text-xs text-red-500 hover:text-red-700">Supprimer</button>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
          <div>
            <label class="text-xs text-gray-500">Type</label>
            <select
              :value="item.item_type"
              @change="updateItem(i, 'item_type', $event.target.value)"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            >
              <option v-for="t in ITEM_TYPES" :key="t.value" :value="t.value">{{ t.label }}</option>
            </select>
          </div>
          <div>
            <label class="text-xs text-gray-500">Description *</label>
            <input
              :value="item.description"
              @input="updateItem(i, 'description', $event.target.value)"
              type="text"
              placeholder="Libellé de la prestation"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-xs text-gray-500">Quantité</label>
            <input
              :value="item.quantity"
              @input="updateItem(i, 'quantity', $event.target.value)"
              type="number"
              min="1"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-xs text-gray-500">Prix unitaire (F) *</label>
            <input
              :value="item.unit_price"
              @input="updateItem(i, 'unit_price', $event.target.value)"
              type="number"
              step="0.01"
              min="0"
              placeholder="0"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-xs text-gray-500">Remise (%)</label>
            <input
              :value="item.discount_percent"
              @input="updateItem(i, 'discount_percent', $event.target.value)"
              type="number"
              min="0"
              max="100"
              step="0.01"
              placeholder="0"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            />
          </div>
          <div>
            <label class="text-xs text-gray-500">Référence</label>
            <input
              :value="item.reference_id"
              @input="updateItem(i, 'reference_id', $event.target.value)"
              type="text"
              placeholder="ID prestation (optionnel)"
              class="mt-0.5 w-full px-2 py-1.5 text-sm rounded border border-gray-300 focus:outline-none focus:ring-1 focus:ring-blue-300"
            />
          </div>
        </div>

        <div class="flex justify-end text-sm font-semibold text-gray-700">
          Sous-total : {{ formatMoney(itemTotal(item)) }}
        </div>
      </div>
    </div>

    <div class="flex items-center justify-between">
      <AppButton size="sm" variant="ghost" @click="addItem">+ Ajouter un article</AppButton>
      <p v-if="modelValue.length" class="text-sm font-bold text-gray-800">
        Total articles : {{ formatMoney(subtotal) }}
      </p>
    </div>
  </div>
</template>
