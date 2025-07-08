// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: false },
  modules: ["@nuxt/ui", "@nuxt/test-utils", "@nuxt/eslint"],
  css: ["~/assets/css/main.css"],
  ui: {
    colors: {
      primary: "zinc",
    },
  },
  app: {
    head: {
      title: "BenchKit",
      meta: [
        { charset: "utf-8" },
        { name: "viewport", content: "width=device-width, initial-scale=1" },
      ],
      link: [{ rel: "icon", type: "image/svg", href: "/manulife.svg" }],
    },
  },
});
