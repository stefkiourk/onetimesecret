<template>
  <!-- Using v-if instead of v-show for modal dialogs is preferred for accessibility:
       - Completely removes content from DOM and accessibility tree when closed
       - Ensures cleaner navigation for screen reader users
       - Prevents focus trapping issues since hidden content cannot receive focus
       - Follows ARIA best practices for modal dialogs
       Performance impact of DOM removal/recreation is negligible for modals -->
  <div v-if="isOpen"
       @keydown="handleKeydown"
       @click.self="closeModal"
       class="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-black/50 backdrop-blur-sm motion-safe:transition-all motion-safe:duration-300"
       :class="{ 'opacity-0': !isOpen }"
       aria-labelledby="settings-modal"
       aria-describedby="settings-modal-description"
       role="dialog"
       aria-modal="true">

    <!-- Description for screen readers -->
    <div id="settings-modal-description"
         class="sr-only">
         Customize your app preferences and settings
    </div>

    <FocusTrap :active="isOpen"
               :initial-focus="() => $refs.closeButton">

      <div class="relative mx-auto w-full max-w-lg sm:max-w-md md:max-w-lg overflow-hidden rounded-2xl bg-white shadow-2xl dark:bg-gray-800 motion-safe:transition-all motion-safe:duration-300 motion-safe:ease-out transform"
           :class="{ 'opacity-0 scale-95': !isOpen, 'opacity-100 scale-100': isOpen }">

        <div class="flex h-[90vh] sm:h-[80vh] flex-col">
          <!-- Modal Header -->
          <div class="flex-shrink-0 flex items-center justify-between bg-gray-50 p-4 dark:bg-gray-700">
            <h2 id="settings-modal"
                class="text-2xl font-bold text-gray-900 dark:text-white">
              Settings
            </h2>
            <div class="flex-shrink-0 flex overflow-x-auto px-6 py-2 gap-2"
                 role="tablist"
                 @keydown="handleTabKeydown"
                 aria-label="Settings sections">
              <button ref="closeButton"
                      @click="closeModal"
                      class="rounded-md p-2 text-gray-500 hover:bg-gray-200 dark:text-gray-300 dark:hover:bg-gray-600 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2"
                      aria-label="Close settings">
                <svg class="h-5 w-5"
                     fill="none"
                     viewBox="0 0 24 24"
                     stroke="currentColor"
                     aria-hidden="true">
                  <path stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Tabs -->
          <div class="flex-shrink-0 flex overflow-x-auto px-6 py-2 gap-2"
               role="tablist"
               aria-label="Settings sections">
            <button v-for="tab in tabs"
                    :key="tab.id"
                    @click="activeTab = tab.id"
                    :aria-selected="activeTab === tab.id"
                    :aria-controls="`tab-${tab.id}`"
                    role="tab"
                    :id="`tab-button-${tab.id}`"
                    :tabindex="activeTab === tab.id ? 0 : -1"
                    class="px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-brandcomp-500 focus:ring-offset-2 transition-colors duration-200"
                    :class="{
                      'bg-brandcomp-100 dark:bg-brandcomp-700': activeTab === tab.id,
                      'hover:bg-gray-200 dark:hover:bg-gray-600': activeTab !== tab.id
                    }">
              {{ tab.label }}
            </button>
          </div>

          <!-- Content -->
          <div class="flex-grow overflow-y-auto p-4 sm:p-6">
            <Suspense>
              <template #default>
                <!-- General Tab -->
                <div v-if="activeTab === 'general'"
                     id="tab-general"
                     role="tabpanel"
                     :aria-labelledby="'tab-button-general'"
                     tabindex="0"
                     class="space-y-8">
                  <GeneralTab @close="closeModal" />
                </div>

                <!-- Data Region Tab -->
                <div v-else-if="activeTab === 'data-region'"
                     id="tab-data-region"
                     role="tabpanel"
                     :aria-labelledby="'tab-button-data-region'"
                     tabindex="0"
                     class="space-y-8">
                  <JurisdictionTab v-if="regionsEnabled" />
                </div>
              </template>

              <template #fallback>
                <div class="flex items-center justify-center h-full">
                  <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-brand-600"
                       role="status">
                    <span class="sr-only">Loading settings content...</span>
                  </div>
                </div>
              </template>
            </Suspense>
          </div>

          <!-- Modal Footer -->
          <div class="flex-shrink-0 flex justify-end bg-gray-50 p-4 dark:bg-gray-700">
            <button @click="closeModal"
                    class="rounded-md bg-brand-600 px-4 py-2 text-white hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2 transition-colors duration-200">
              Done
            </button>
          </div>
        </div>
      </div>
    </FocusTrap>
  </div>
</template>

<style scoped>
/* Add focus styles that work in all color schemes */
.focus-visible:focus {
  @apply outline-none ring-2 ring-brand-500 ring-offset-2 dark:ring-offset-gray-800;
}

/* Hide scrollbar but keep functionality */
.scrollbar-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
</style>

<script setup lang="ts">
import { useWindowProps } from '@/composables/useWindowProps';
import { FocusTrap } from 'focus-trap-vue';
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import GeneralTab from './settings/GeneralTab.vue';
import JurisdictionTab from './settings/JurisdictionTab.vue';

const { regions_enabled: regionsEnabled } = useWindowProps(['regions_enabled']);

interface Tab {
  id: string;
  label: string;
}

const props = defineProps<{
  isOpen: boolean;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
}>();

const closeButton = ref<HTMLButtonElement | null>(null);
let previouslyFocusedElement: HTMLElement | null = null;


const tabs = ref<Tab[]>([
  { id: 'general', label: 'General' },
]);

if (regionsEnabled.value) {
  tabs.value.push({ id: 'data-region', label: 'Data Region' });
}
const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape') {
    closeModal();
  }
};
const activeTab = ref<Tab['id']>(tabs.value[0].id);

const closeModal = () => {
  emit('close');
  // Return focus to the previous element when modal closes
  nextTick(() => {
    previouslyFocusedElement?.focus();
  });
};

// Reset tab when modal closes and re-opens
watch(() => props.isOpen, (newValue) => {
  if (newValue) {
    activeTab.value = tabs.value[0].id;
    // Store the currently focused element when modal opens
    previouslyFocusedElement = document.activeElement as HTMLElement;
  }
});

// Clean up when component is destroyed
onBeforeUnmount(() => {
  previouslyFocusedElement = null;
});

onMounted(() => {
  if (!closeButton.value) {
    console.warn('Initial focus element not found for settings modal');
  }
});

const handleTabKeydown = (e: KeyboardEvent) => {
  const tabButtons = tabs.value.map(tab => tab.id);
  const currentIndex = tabButtons.indexOf(activeTab.value);

  switch (e.key) {
    case 'ArrowRight':
    case 'ArrowDown':
      e.preventDefault();
      activeTab.value = tabButtons[(currentIndex + 1) % tabButtons.length];
      break;
    case 'ArrowLeft':
    case 'ArrowUp':
      e.preventDefault();
      activeTab.value = tabButtons[(currentIndex - 1 + tabButtons.length) % tabButtons.length];
      break;
    case 'Home':
      e.preventDefault();
      activeTab.value = tabButtons[0];
      break;
    case 'End':
      e.preventDefault();
      activeTab.value = tabButtons[tabButtons.length - 1];
      break;
  }
};
</script>
