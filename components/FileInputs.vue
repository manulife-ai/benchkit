<template>
  <div class="w-full space-y-4">
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
        File Upload
      </h3>
      <UBadge v-if="selectedFiles.length > 0" variant="soft" color="primary">
        {{ selectedFiles.length }} file{{
          selectedFiles.length !== 1 ? "s" : ""
        }}
        selected
      </UBadge>
    </div>

    <!-- File Input Area -->
    <div
      ref="dropZone"
      class="relative rounded-lg border-2 border-dashed border-gray-300 p-8 text-center transition-colors hover:border-gray-400 dark:border-gray-600 dark:hover:border-gray-500"
      :class="{
        'border-primary-500 bg-primary-50 dark:bg-primary-950': isDragOver,
        'border-red-500 bg-red-50 dark:bg-red-950': hasError,
      }"
      @drop="handleDrop"
      @dragover="handleDragOver"
      @dragenter="handleDragEnter"
      @dragleave="handleDragLeave"
    >
      <input
        ref="fileInput"
        type="file"
        multiple
        :accept="acceptedTypes"
        class="absolute inset-0 h-full w-full cursor-pointer opacity-0"
        @change="handleFileSelect"
      />

      <div class="space-y-4">
        <UIcon
          name="i-heroicons-cloud-arrow-up"
          class="mx-auto h-12 w-12 text-gray-400"
        />

        <div>
          <p class="text-lg font-medium text-gray-700 dark:text-gray-300">
            Drop files here or click to browse
          </p>
          <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
            Supports PDF, TXT, and image files (PNG, JPG, JPEG, GIF, WebP)
          </p>
          <p class="mt-1 text-xs text-gray-400 dark:text-gray-500">
            Maximum file size: {{ formatFileSize(maxFileSize) }}
          </p>
        </div>

        <UButton variant="outline" size="sm" @click="triggerFileSelect">
          Choose Files
        </UButton>
      </div>
    </div>

    <!-- Error Message -->
    <UAlert
      v-if="errorMessage"
      color="red"
      variant="soft"
      :title="errorMessage"
      @close="clearError"
    />

    <!-- Selected Files List -->
    <div v-if="selectedFiles.length > 0" class="space-y-2">
      <h4 class="font-medium text-gray-900 dark:text-white">Selected Files:</h4>
      <div class="space-y-2">
        <div
          v-for="(file, index) in selectedFiles"
          :key="index"
          class="flex items-center justify-between rounded-lg bg-gray-50 p-3 dark:bg-gray-800"
        >
          <div class="flex items-center space-x-3">
            <UIcon :name="getFileIcon(file)" class="h-5 w-5 text-gray-500" />
            <div>
              <p class="text-sm font-medium text-gray-900 dark:text-white">
                {{ file.name }}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ formatFileSize(file.size) }} • {{ getFileType(file) }}
              </p>
            </div>
          </div>

          <UButton
            variant="ghost"
            color="red"
            size="xs"
            @click="removeFile(index)"
          >
            <UIcon name="i-heroicons-x-mark" class="h-4 w-4" />
          </UButton>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="flex space-x-2 pt-2">
        <UButton
          color="primary"
          @click="handleUpload"
          :disabled="isUploading"
          :loading="isUploading"
        >
          Upload Files
        </UButton>
        <UButton variant="outline" color="gray" @click="clearFiles">
          Clear All
        </UButton>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from "vue";

// Props
const props = defineProps({
  maxFileSize: {
    type: Number,
    default: 10 * 1024 * 1024, // 10MB default
  },
  maxFiles: {
    type: Number,
    default: 10,
  },
});

// Emits
const emit = defineEmits(["files-selected", "upload-complete", "upload-error"]);

// Reactive data
const selectedFiles = ref([]);
const isDragOver = ref(false);
const errorMessage = ref("");
const isUploading = ref(false);
const fileInput = ref(null);
const dropZone = ref(null);

// Computed
const acceptedTypes = computed(() => {
  return [
    ".pdf",
    ".txt",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    "image/*",
    "text/plain",
    "application/pdf",
  ].join(",");
});

const hasError = computed(() => !!errorMessage.value);

// File type validation
const isValidFileType = (file) => {
  const validTypes = [
    "application/pdf",
    "text/plain",
    "image/png",
    "image/jpeg",
    "image/jpg",
    "image/gif",
    "image/webp",
  ];

  return validTypes.some(
    (type) =>
      file.type === type ||
      (type.includes("image/") && file.type.startsWith("image/")),
  );
};

// File size validation
const isValidFileSize = (file) => {
  return file.size <= props.maxFileSize;
};

// Get file icon based on type
const getFileIcon = (file) => {
  if (file.type === "application/pdf") {
    return "i-heroicons-document-text";
  } else if (file.type === "text/plain") {
    return "i-heroicons-document";
  } else if (file.type.startsWith("image/")) {
    return "i-heroicons-photo";
  }
  return "i-heroicons-document";
};

// Get readable file type
const getFileType = (file) => {
  if (file.type === "application/pdf") return "PDF";
  if (file.type === "text/plain") return "Text";
  if (file.type.startsWith("image/")) return "Image";
  return "Unknown";
};

// Format file size
const formatFileSize = (bytes) => {
  if (bytes === 0) return "0 Bytes";
  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
};

// File handling methods
const validateFile = (file) => {
  if (!isValidFileType(file)) {
    return `File "${file.name}" is not a supported type. Please upload PDF, TXT, or image files.`;
  }

  if (!isValidFileSize(file)) {
    return `File "${file.name}" is too large. Maximum size is ${formatFileSize(props.maxFileSize)}.`;
  }

  return null;
};

const addFiles = (files) => {
  clearError();

  const newFiles = Array.from(files);
  const errors = [];

  // Check total file count
  if (selectedFiles.value.length + newFiles.length > props.maxFiles) {
    errorMessage.value = `Cannot upload more than ${props.maxFiles} files.`;
    return;
  }

  // Validate each file
  for (const file of newFiles) {
    const error = validateFile(file);
    if (error) {
      errors.push(error);
    } else {
      // Check for duplicates
      const isDuplicate = selectedFiles.value.some(
        (existing) =>
          existing.name === file.name && existing.size === file.size,
      );

      if (!isDuplicate) {
        selectedFiles.value.push(file);
      }
    }
  }

  if (errors.length > 0) {
    errorMessage.value = errors[0]; // Show first error
  }

  if (selectedFiles.value.length > 0) {
    emit("files-selected", selectedFiles.value);
  }
};

const removeFile = (index) => {
  selectedFiles.value.splice(index, 1);
  emit("files-selected", selectedFiles.value);
};

const clearFiles = () => {
  selectedFiles.value = [];
  clearError();
  emit("files-selected", []);
};

const clearError = () => {
  errorMessage.value = "";
};

const triggerFileSelect = () => {
  fileInput.value?.click();
};

// Event handlers
const handleFileSelect = (event) => {
  const files = event.target.files;
  if (files && files.length > 0) {
    addFiles(files);
  }
};

const handleDrop = (event) => {
  event.preventDefault();
  isDragOver.value = false;

  const files = event.dataTransfer.files;
  if (files && files.length > 0) {
    addFiles(files);
  }
};

const handleDragOver = (event) => {
  event.preventDefault();
};

const handleDragEnter = (event) => {
  event.preventDefault();
  isDragOver.value = true;
};

const handleDragLeave = (event) => {
  event.preventDefault();
  // Only set to false if we're leaving the drop zone completely
  if (!dropZone.value?.contains(event.relatedTarget)) {
    isDragOver.value = false;
  }
};

// Upload handler (you can customize this based on your needs)
const handleUpload = async () => {
  if (selectedFiles.value.length === 0) return;

  isUploading.value = true;
  clearError();

  try {
    // Here you would implement your actual upload logic
    // For now, we'll just simulate an upload
    await new Promise((resolve) => setTimeout(resolve, 2000));

    emit("upload-complete", selectedFiles.value);

    // Optionally clear files after successful upload
    clearFiles();
  } catch (error) {
    errorMessage.value = "Upload failed. Please try again.";
    emit("upload-error", error);
  } finally {
    isUploading.value = false;
  }
};

// Expose methods for parent component use
defineExpose({
  clearFiles,
  getSelectedFiles: () => selectedFiles.value,
  addFiles,
});
</script>
