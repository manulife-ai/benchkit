<template>
  <div class="space-y-8">
    <div
      class="flex items-center justify-between border-b border-gray-200 pb-6"
    >
      <div>
        <h1 class="font-serif text-2xl leading-tight font-normal text-gray-700">
          Review Test Cases
        </h1>
      </div>
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 gap-8 xl:grid-cols-2 xl:items-start">
      <!-- Original Data Panel -->
      <UCard>
        <template #header>
          <div>
            <h2 class="text-xl font-medium text-gray-800">Input</h2>
            <p class="text-sm text-gray-600">Source data</p>
          </div>
        </template>

        <div class="relative">
          <div class="absolute top-3 right-3 z-10">
            <UBadge color="neutral" variant="soft" size="sm">
              Read Only
            </UBadge>
          </div>
          <div
            class="max-h-[70dvh] overflow-auto rounded-lg border border-gray-200 bg-gray-50 p-6"
          >
            <pre class="text-sm leading-relaxed text-gray-700">{{
              JSON.stringify(originalData, null, 2)
            }}</pre>
          </div>
        </div>
      </UCard>

      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-medium text-gray-800">Output</h2>
              <p class="text-sm text-gray-600">Edit and validate</p>
            </div>
            <div class="flex gap-3">
              <UButton @click="resetData" variant="outline" color="neutral">
                Reset Changes
              </UButton>
              <UTooltip text="Shortcut" :kbds="['meta', 'enter']">
                <UButton @click="submitValidation" color="neutral">
                  Submit Validation
                </UButton>
              </UTooltip>
            </div>
          </div>
        </template>

        <div class="max-h-[70dvh] overflow-auto rounded-lg bg-gray-50/30 p-2">
          <JsonValidator
            v-model="validatedData"
            @update:model-value="onDataChange"
          />
        </div>
      </UCard>
    </div>
  </div>
</template>

<script setup lang="ts">
// Import the mock data
import mockData from "~/sandbox/mock-extraction.json";

const toast = useToast();

defineShortcuts({
  meta_enter: () => submitValidation(),
});

// Reactive data
const originalData = ref(mockData);
const validatedData = ref(JSON.parse(JSON.stringify(mockData)));

// Handle data changes
const onDataChange = (newData: any) => {
  validatedData.value = newData;
};

// Reset to original data
const resetData = () => {
  validatedData.value = JSON.parse(JSON.stringify(originalData.value));
};

// Submit validation (placeholder for future implementation)
const submitValidation = () => {
  console.log("Submitting validation:", validatedData.value);

  toast.add({
    title: "Success",
    description: "Validation submitted successfully!",
    color: "success",
  });
};
</script>
