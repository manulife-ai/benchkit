<template>
  <div class="space-y-8">
    <div
      class="flex items-center justify-between border-b border-gray-200 pb-6"
    >
      <div>
        <h1 class="font-serif text-2xl leading-tight font-normal text-gray-700">
          Review samples
        </h1>
      </div>
      <!-- Navigation Controls -->
      <div class="flex items-center gap-3">
        <UTooltip text="Shortcut" :kbds="['arrowleft']">
          <UButton
            @click="previousSample"
            :disabled="currentIndex === 0"
            variant="outline"
            color="neutral"
            icon="i-heroicons-chevron-left"
          >
            Previous
          </UButton>
        </UTooltip>

        <UTooltip text="Shortcut" :kbds="['arrowright']">
          <UButton
            @click="nextSample"
            :disabled="currentIndex === totalSamples - 1"
            variant="outline"
            color="neutral"
            icon="i-heroicons-chevron-right"
            trailing
          >
            Next
          </UButton>
        </UTooltip>
      </div>
    </div>

    <!-- Progress Bar -->
    <div class="space-y-2">
      <div class="flex justify-between text-sm text-gray-600">
        <span>Progress</span>

        <span> Sample {{ currentIndex + 1 }} of {{ totalSamples }} </span>
        <span>{{ Math.round(progress) }}%</span>
      </div>
      <UProgress v-model="progress" :max="100" color="primary" />
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 gap-8 xl:grid-cols-2 xl:items-start">
      <!-- Original Data Panel -->
      <UCard>
        <template #header>
          <div>
            <h2 class="text-xl font-medium text-gray-800">Input</h2>
            <p class="text-sm text-gray-600">
              {{ originalData.filename }}
            </p>
          </div>
        </template>

        <div class="relative">
          <div class="absolute top-3 right-3 z-10">
            <UBadge color="neutral" variant="soft" size="sm">
              Read Only
            </UBadge>
          </div>
          <div
            class="flex h-[68dvh] items-center justify-center overflow-auto rounded-lg border border-gray-200 bg-gray-50"
          >
            <NuxtImg src="mock-document.png" alt="Input" />
          </div>
        </div>
      </UCard>

      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-medium text-gray-800">Output</h2>
              <p class="text-sm text-gray-600">
                {{ originalData.filename }}
              </p>
            </div>
            <div class="flex gap-3">
              <UButton
                @click="copyToClipboard"
                variant="outline"
                color="neutral"
                icon="i-heroicons-clipboard"
              />
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

        <div class="h-[68dvh] overflow-auto rounded-lg bg-gray-50/30 p-2">
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
  arrowleft: () => previousSample(),
  arrowright: () => nextSample(),
});

// Simulate hundreds of samples by creating variations of the mock data
const generateMockSamples = () => {
  const samples = [];
  for (let i = 0; i < 250; i++) {
    const sample = JSON.parse(JSON.stringify(mockData));
    // Add some variation to make each sample unique
    sample.filename = `image_${i + 1}`;
    sample.extraction.information_about_the_owner.policy_account_owner_1.name = `Sample User ${i + 1}`;
    samples.push(sample.extraction);
  }
  return samples;
};

// Sample data and navigation
const allSamples = ref(generateMockSamples());
const currentIndex = ref(0);
const totalSamples = computed(() => allSamples.value.length);

// Current sample data
const originalData = computed(() => allSamples.value[currentIndex.value]);
const validatedData = ref(JSON.parse(JSON.stringify(allSamples.value[0])));

// Progress calculation
const progress = computed(
  () => ((currentIndex.value + 1) / totalSamples.value) * 100,
);

// Navigation functions
const previousSample = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--;
    validatedData.value = JSON.parse(JSON.stringify(originalData.value));
  }
};

const nextSample = () => {
  if (currentIndex.value < totalSamples.value - 1) {
    currentIndex.value++;
    validatedData.value = JSON.parse(JSON.stringify(originalData.value));
  }
};

// Handle data changes
const onDataChange = (newData: any) => {
  validatedData.value = newData;
};

// Reset to original data
const resetData = () => {
  validatedData.value = JSON.parse(JSON.stringify(originalData.value));
  toast.add({
    title: "Reset",
    description: "Data reset to original",
    icon: "i-heroicons-arrow-path",
  });
};

// Copy to clipboard function
const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(
      JSON.stringify(validatedData.value, null, 2),
    );
    toast.add({
      title: "Copied",
      description: "Data copied to clipboard",
      icon: "i-heroicons-clipboard",
    });
  } catch (err) {
    toast.add({
      title: "Error",
      description: "Failed to copy to clipboard",
      color: "error",
      icon: "i-heroicons-x-circle",
    });
  }
};

// Submit validation (placeholder for future implementation)
const submitValidation = () => {
  console.log("Submitting validation:", validatedData.value);

  nextSample();

  toast.add({
    title: "Success",
    description: `Sample ${currentIndex.value + 1} validation submitted successfully!`,
    icon: "i-heroicons-check-circle",
  });
};
</script>
