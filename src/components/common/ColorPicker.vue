<template>
  <div class="relative">
    <label :id="id + '-label'"
           class="sr-only">{{ label }}</label>
    <div class="group
            flex items-center gap-3
            h-11 px-3
            rounded-lg
            border border-gray-200
            bg-white
            dark:bg-gray-800
            dark:border-gray-600
            shadow-sm">
      <!-- Color Preview Circle -->
      <div class="relative flex items-center">
        <div class="w-6 h-6
            rounded-full
            border-2 border-white ring-1 ring-gray-200
            dark:border-gray-700 dark:ring-gray-600
            shadow-sm"
             :style="{ backgroundColor: modelValue }"
             aria-hidden="true">
          <input type="color"
                 :value="modelValue"
                 @input="updateColor"
                 :name="name"
                 class="absolute inset-0
             w-full h-full
             opacity-0
             cursor-pointer"
                 :aria-labelledby="id + '-label'">
        </div>
      </div>

      <!-- Hex Input -->
      <div class="relative flex items-center">
        <span class="absolute left-0
             text-sm font-medium
             text-gray-400
             dark:text-gray-500"
              aria-hidden="true">#</span>
        <input type="text"
               :value="modelValue.replace('#', '')"
               @input="(e) => updateColor(e, true)"
               :name="name"
               class="pl-4 p-0
             w-[5.5rem]
             border-none
             bg-transparent
             text-sm font-medium uppercase
             text-gray-900
             placeholder-gray-400
             dark:text-gray-100
             focus:ring-0"
               pattern="[0-9A-Fa-f]{6}"
               placeholder="2ACFCF"
               maxlength="6"
               spellcheck="false"
               :aria-label="label">
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  modelValue: string;
  label?: string;
  name?: string;
  id?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
}>();

// Provide default props
const label = computed(() => props.label || 'Color Picker');
const id = computed(() => props.id || 'color-picker');
const name = computed(() => props.name || 'color');

const updateColor = (event: Event, isText = false) => {
  const target = event.target as HTMLInputElement;
  let newColor = target.value;

  if (isText) {
    // Handle text input (without #)
    newColor = `#${newColor}`.toUpperCase();
  } else {
    // Handle color picker input (with #)
    newColor = newColor.toUpperCase();
  }

  // Validate hex color
  if (/^#[0-9A-F]{6}$/i.test(newColor)) {
    emit('update:modelValue', newColor);
  }
};
</script>
