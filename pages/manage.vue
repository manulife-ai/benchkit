<template>
  <div>
    <h1 class="font-serif text-2xl leading-tight font-normal text-gray-700">
      Manage test cases
    </h1>
    <UTabs
      variant="link"
      color="neutral"
      :content="false"
      :items="items"
      class="mt-2 w-full"
    />
  </div>
</template>

<script setup lang="ts">
import type { TabsItem } from "@nuxt/ui";

const items = ref<TabsItem[]>([
  {
    label: "Users",
    class: "cursor-pointer",
  },
  {
    label: "Projects",
  },
  {
    label: "Test Cases",
  },
]);
</script>
