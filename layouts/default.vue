<template>
  <UApp>
    <div class="flex min-h-screen flex-col p-6 antialiased">
      <div class="flex items-center justify-between gap-2">
        <div class="flex items-center gap-2">
          <h1
            class="font-serif text-4xl leading-tight font-normal text-gray-700"
          >
            BenchKit
          </h1>
          <UIcon name="i-lucide-list-checks" class="size-5 text-gray-600" />
        </div>
        <nav>
          <ul class="flex space-x-6">
            <li v-for="item in navItems" :key="item.title">
              <ULink
                raw
                :to="item.link"
                class="font-serif text-xl leading-tight"
                inactive-class="text-muted opacity-75"
              >
                {{ item.title }}
              </ULink>
            </li>
          </ul>
        </nav>

        <UDropdownMenu
          :items="userMenuItems"
          :content="{
            align: 'end',
            side: 'bottom',
            sideOffset: 8,
          }"
          :ui="{
            content: 'w-48',
          }"
        >
          <UButton
            :avatar="{
              src: 'https://github.com/romainmartinez.png',
            }"
            size="xl"
            color="neutral"
            variant="link"
            class="cursor-pointer"
          />
        </UDropdownMenu>
      </div>

      <div class="mt-6 flex-1">
        <slot />
      </div>
      <p class="mt-6 text-center text-sm/6 text-gray-600">
        &copy; 2025 Manulife, Inc. All rights reserved.
      </p>
    </div>
  </UApp>
</template>

<script setup>
const navItems = [
  {
    title: "Manage",
    link: "/manage",
  },
  {
    title: "Review",
    link: "/review",
  },
  {
    title: "Analyse",
    link: "/analyse",
  },
];

// TODO: implement handlers
const userMenuItems = [
  {
    label: "Profile",
    icon: "i-lucide-user",
  },
  {
    label: "Settings",
    icon: "i-lucide-cog",
  },
  {
    label: "Support",
    icon: "i-lucide-life-buoy",
  },
  {
    label: "Logout",
    icon: "i-lucide-log-out",
  },
];
</script>

<style>
button {
  @apply cursor-pointer;
}
</style>
