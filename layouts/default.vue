<template>
  <UApp>
    <div class="p-6 antialiased">
      <div class="flex items-center gap-2">
        <h1 class="font-serif text-4xl leading-tight font-normal text-gray-700">
          BenchKit
        </h1>
        <UIcon name="i-lucide-list-checks" class="size-5 text-gray-600" />
      </div>

      <slot />
    </div>
  </UApp>
</template>
