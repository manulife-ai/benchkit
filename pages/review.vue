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
            :disabled="currentIndex === 0 || isLoading || totalSamples === 0"
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
            :disabled="
              currentIndex === totalSamples - 1 ||
              isLoading ||
              totalSamples === 0
            "
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
    <div v-if="totalSamples > 0" class="space-y-2">
      <div class="flex justify-between text-sm text-gray-600">
        <span>Progress</span>

        <span> Sample {{ currentIndex + 1 }} of {{ totalSamples }} </span>
        <span>{{ Math.round(progress) }}%</span>
      </div>
      <UProgress v-model="progress" :max="100" color="primary" />
    </div>

    <!-- Main Content Grid -->
    <div v-if="isLoading" class="flex items-center justify-center py-12">
      <div class="text-center">
        <UIcon
          name="i-heroicons-arrow-path"
          class="mx-auto h-8 w-8 animate-spin text-gray-400"
        />
        <p class="mt-2 text-gray-600">Loading test cases...</p>
      </div>
    </div>

    <div v-else-if="totalSamples === 0" class="py-12 text-center">
      <div class="mx-auto max-w-md">
        <UIcon
          name="i-heroicons-document-magnifying-glass"
          class="mx-auto h-12 w-12 text-gray-300"
        />
        <h3 class="mt-4 text-lg font-medium text-gray-900">
          No samples to review
        </h3>
        <p class="mt-2 text-gray-600">
          There are no unvalidated test cases available for review. Create some
          test cases in the Manage section first.
        </p>
        <UButton to="/manage" class="mt-4" variant="outline">
          Go to Manage
        </UButton>
      </div>
    </div>

    <div v-else class="grid grid-cols-1 gap-8 xl:grid-cols-2 xl:items-start">
      <!-- Original Data Panel -->
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <h2 class="text-xl font-medium text-gray-800">Input</h2>
              <p class="text-sm text-gray-600">
                {{ getCurrentInputFile?.filename || "No file" }}
              </p>
            </div>
            <!-- File navigation controls -->
            <div
              v-if="currentInputFiles.length > 1"
              class="flex items-center gap-2"
            >
              <UButton
                @click="previousInputFile"
                :disabled="currentInputFileIndex === 0"
                variant="ghost"
                size="sm"
                icon="i-heroicons-chevron-left"
              />
              <span class="text-sm text-gray-600">
                {{ currentInputFileIndex + 1 }} of
                {{ currentInputFiles.length }}
              </span>
              <UButton
                @click="nextInputFile"
                :disabled="
                  currentInputFileIndex === currentInputFiles.length - 1
                "
                variant="ghost"
                size="sm"
                icon="i-heroicons-chevron-right"
              />
            </div>
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
            <div v-if="isLoading" class="text-center">
              <UIcon
                name="i-heroicons-arrow-path"
                class="h-8 w-8 animate-spin text-gray-400"
              />
              <p class="mt-2 text-gray-600">Loading samples...</p>
            </div>
            <div
              v-else-if="!getCurrentInputFile"
              class="text-center text-gray-500"
            >
              <UIcon
                name="i-heroicons-document"
                class="h-12 w-12 text-gray-300"
              />
              <p class="mt-2">No input file available</p>
            </div>
            <!-- Image preview -->
            <NuxtImg
              v-else-if="getCurrentInputFile?.type === 'img'"
              :src="getCurrentInputFile.file"
              :alt="getCurrentInputFile.filename"
              class="max-h-full max-w-full object-contain"
            />
            <!-- PDF preview -->
            <div
              v-else-if="getCurrentInputFile?.type === 'pdf'"
              class="h-full w-full"
            >
              <iframe
                :src="getCurrentInputFile.file"
                class="h-full w-full border-0"
                title="PDF Preview"
              />
            </div>
            <!-- Text file preview -->
            <div
              v-else-if="getCurrentInputFile?.type === 'txt'"
              class="h-full w-full overflow-auto p-4"
            >
              <pre class="text-sm whitespace-pre-wrap text-gray-800">{{
                textFileContent
              }}</pre>
            </div>
            <!-- JSON file preview -->
            <div
              v-else-if="getCurrentInputFile?.type === 'json'"
              class="h-full w-full overflow-auto p-4"
            >
              <JsonValidator :model-value="jsonFileContent" :readonly="true" />
            </div>
            <!-- Default file display -->
            <div v-else class="text-center">
              <UIcon
                :name="getFileIcon(getCurrentInputFile?.type)"
                class="h-12 w-12 text-gray-400"
              />
              <p class="mt-2 text-sm text-gray-600">
                {{ getCurrentInputFile?.filename }}
              </p>
              <p class="text-xs text-gray-500">
                {{
                  (getCurrentInputFile?.type as string)?.toUpperCase() ||
                  "UNKNOWN"
                }}
                file
              </p>
            </div>
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
                <UButton
                  @click="submitValidation"
                  color="neutral"
                  :loading="isSubmitting"
                  :disabled="isLoading || totalSamples === 0"
                >
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
import type { ITestCase } from "~/models";

const toast = useToast();
const { getTestCases, validateTestCase } = useTestCases();

defineShortcuts({
  meta_enter: () => submitValidation(),
  arrowleft: () => previousSample(),
  arrowright: () => nextSample(),
});

// Sample data and navigation
const allSamples = ref<ITestCase[]>([]);
const currentIndex = ref(0);
const totalSamples = computed(() => allSamples.value.length);
const isLoading = ref(true);
const isSubmitting = ref(false);

// Input file navigation
const currentInputFileIndex = ref(0);

// Current sample data
const originalData = computed(() => {
  const current = allSamples.value[currentIndex.value];
  if (!current) return { filename: "No file", _id: null };
  return {
    ...current.original,
    filename: current.inputs?.[0]?.filename || "No file",
    _id: current._id,
  };
});

const validatedData = ref({});

// Progress calculation
const progress = computed(
  () => ((currentIndex.value + 1) / totalSamples.value) * 100,
);

// Load test cases from database
const loadTestCases = async () => {
  isLoading.value = true;
  try {
    const testCases = await getTestCases();

    // Filter for unvalidated test cases or those with partial validation
    allSamples.value = testCases.filter(
      (tc) => !tc.validated || tc.validated.length === 0,
    );

    if (allSamples.value.length > 0) {
      validatedData.value = JSON.parse(
        JSON.stringify(allSamples.value[0].original),
      );
    } else {
      toast.add({
        title: "No samples found",
        description:
          "No test cases available for review. Create some in the Manage section.",
        color: "warning",
      });
    }
  } catch (error: any) {
    toast.add({
      title: "Error loading samples",
      description: "Failed to load test cases from database",
      color: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

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

// Submit validation
const submitValidation = async () => {
  if (!originalData.value._id) {
    toast.add({
      title: "Error",
      description: "No valid test case selected",
      color: "error",
    });
    return;
  }

  isSubmitting.value = true;

  try {
    // TODO: Get current user ID (for now using a placeholder)
    const currentUserId = "60f7b3b3b3b3b3b3b3b3b3b3"; // This should come from auth

    await validateTestCase(originalData.value._id, {
      user: currentUserId,
      comment: "Validation completed via review interface",
      data: validatedData.value,
    });

    toast.add({
      title: "Success",
      description: `Sample ${currentIndex.value + 1} validation submitted successfully!`,
      icon: "i-heroicons-check-circle",
      color: "success",
    });

    // Remove the validated case from the list
    allSamples.value.splice(currentIndex.value, 1);

    // Adjust current index if needed
    if (
      currentIndex.value >= allSamples.value.length &&
      allSamples.value.length > 0
    ) {
      currentIndex.value = allSamples.value.length - 1;
    }

    // Load next sample if available
    if (allSamples.value.length > 0) {
      validatedData.value = JSON.parse(JSON.stringify(originalData.value));
    } else {
      toast.add({
        title: "All done!",
        description: "No more samples to review",
        color: "success",
      });
    }
  } catch (error: any) {
    toast.add({
      title: "Error",
      description: "Failed to submit validation",
      color: "error",
    });
  } finally {
    isSubmitting.value = false;
  }
};

// Get input file for display
const currentInputFiles = computed(() => {
  const current = allSamples.value[currentIndex.value];
  return current?.inputs || [];
});

const getCurrentInputFile = computed(() => {
  const files = currentInputFiles.value;
  if (!files.length) return null;
  return files[currentInputFileIndex.value] || null;
});

// Input file navigation functions
const previousInputFile = () => {
  if (currentInputFileIndex.value > 0) {
    currentInputFileIndex.value--;
  }
};

const nextInputFile = () => {
  if (currentInputFileIndex.value < currentInputFiles.value.length - 1) {
    currentInputFileIndex.value++;
  }
};

// File content helpers
const textFileContent = ref("");
const jsonFileContent = ref({});

const loadFileContent = async () => {
  const currentFile = getCurrentInputFile.value;
  if (!currentFile) return;

  try {
    if (currentFile.type === "txt") {
      const response = await fetch(currentFile.file);
      textFileContent.value = await response.text();
    } else if (currentFile.type === "json") {
      const response = await fetch(currentFile.file);
      jsonFileContent.value = await response.json();
    }
  } catch (error) {
    if (currentFile.type === "txt") {
      textFileContent.value = "Error loading text file content";
    } else if (currentFile.type === "json") {
      jsonFileContent.value = { error: "Error loading JSON file content" };
    }
  }
};

const getFileIcon = (fileType?: string) => {
  switch (fileType) {
    case "pdf":
      return "i-heroicons-document-text";
    case "txt":
      return "i-heroicons-document-text";
    case "json":
      return "i-heroicons-code-bracket";
    case "img":
      return "i-heroicons-photo";
    default:
      return "i-heroicons-document";
  }
};

// Initialize on mount
onMounted(() => {
  loadTestCases();
});

// Watch for index changes to update validated data
watch(currentIndex, () => {
  if (allSamples.value.length > 0) {
    validatedData.value = JSON.parse(JSON.stringify(originalData.value));
    currentInputFileIndex.value = 0; // Reset input file index when changing samples
  }
});

// Watch for input file changes to load content
watch(
  getCurrentInputFile,
  () => {
    loadFileContent();
  },
  { immediate: true },
);
</script>
