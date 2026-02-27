<template>
  <div class="space-y-4">
    <!-- Group simple fields by pairs -->
    <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
      <template v-for="(value, key) in modelValue" :key="key">
        <!-- Simple Field (String/Number/Boolean) -->
        <UFormField
          v-if="isSimpleType(value)"
          :label="formatLabel(key)"
          :name="key"
        >
          <UInput
            :model-value="String(value)"
            @update:model-value="updateValue(key, $event)"
            :placeholder="`Enter ${formatLabel(key)}`"
            class="w-full"
          />
        </UFormField>

        <!-- Null/Undefined Field -->
        <UFormField
          v-else-if="value === null || value === undefined"
          :label="formatLabel(key)"
          :name="key"
        >
          <UInput
            :model-value="String(value || '')"
            @update:model-value="updateValue(key, $event)"
            :placeholder="`Enter ${formatLabel(key)}`"
            class="w-full"
          />
        </UFormField>
      </template>
    </div>

    <!-- Complex fields (Arrays and Objects) take full width -->
    <div class="space-y-6">
      <template v-for="(value, key) in modelValue" :key="key">
        <!-- Array Field -->
        <div v-if="Array.isArray(value)" class="space-y-4">
          <div class="border-l border-gray-300 pl-4">
            <label class="block text-sm font-bold text-gray-700">{{
              formatLabel(key)
            }}</label>

            <div class="space-y-3">
              <div
                v-for="(item, index) in value"
                :key="`${key}-${index}`"
                class="space-y-2 border-l border-gray-200 pl-3"
              >
                <div class="flex items-center justify-between">
                  <span class="text-sm font-bold text-gray-600"
                    >Item {{ index + 1 }}</span
                  >
                </div>

                <!-- Simple array item -->
                <UFormField
                  v-if="isSimpleType(item)"
                  :label="`Value`"
                  :name="`${key}_${index}`"
                >
                  <UInput
                    :model-value="String(item)"
                    @update:model-value="updateArrayItem(key, index, $event)"
                    :placeholder="`Enter value`"
                    class="w-full"
                  />
                </UFormField>

                <!-- Complex array item (object) -->
                <div v-else-if="typeof item === 'object' && item !== null">
                  <JsonValidator
                    :model-value="item"
                    @update:model-value="updateArrayItem(key, index, $event)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Object Field (Nested) -->
        <div
          v-else-if="typeof value === 'object' && value !== null"
          class="space-y-3"
        >
          <div class="border-l border-gray-300 pl-4">
            <label class="block text-sm font-bold text-gray-700">{{
              formatLabel(key)
            }}</label>
            <JsonValidator
              :model-value="value"
              @update:model-value="updateValue(key, $event)"
            />
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  modelValue: Record<string, any>;
}

interface Emits {
  (e: "update:modelValue", value: Record<string, any>): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

// Helper function to check if a value is a simple type (string, number, boolean)
const isSimpleType = (value: any): boolean => {
  const type = typeof value;
  return type === "string" || type === "number" || type === "boolean";
};

// Helper function to format labels (convert snake_case to Title Case)
const formatLabel = (key: string): string => {
  return key
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
};

// Helper function to convert string input to appropriate type
const convertValue = (originalValue: any, newStringValue: string): any => {
  if (typeof originalValue === "number") {
    const num = Number(newStringValue);
    return isNaN(num) ? originalValue : num;
  }

  if (typeof originalValue === "boolean") {
    const lower = newStringValue.toLowerCase();
    if (lower === "true") return true;
    if (lower === "false") return false;
    return originalValue;
  }

  return newStringValue;
};

// Update a specific key-value pair
const updateValue = (key: string, newValue: any) => {
  const updated = { ...props.modelValue };

  // If it's a string input for a typed value, convert it
  if (typeof newValue === "string" && typeof updated[key] !== "string") {
    updated[key] = convertValue(updated[key], newValue);
  } else {
    updated[key] = newValue;
  }

  emit("update:modelValue", updated);
};

// Update specific array item
const updateArrayItem = (key: string, index: number, newValue: any) => {
  const updated = { ...props.modelValue };
  const array = updated[key] as any[];

  // Handle type conversion for simple types
  if (typeof newValue === "string" && isSimpleType(array[index])) {
    array[index] = convertValue(array[index], newValue);
  } else {
    array[index] = newValue;
  }

  emit("update:modelValue", updated);
};
</script>
