const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  darkMode: "class",
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,html,rb}",
    "./config/locales/*.yml",
  ],
  theme: {
    extend: {
      animation: {
        "pulse-fast": "pulse 1.5s cubic-bezier(0.6, 0, 0.4, 1) infinite",
      },
      backgroundImage: {
        "external-link-light": "url('heroicons/arrow-top-right-on-square.svg')",
        "external-link-dark":
          "url('heroicons/arrow-top-right-on-square-dark.svg')",
      },
      fontFamily: {
        // sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      letterSpacing: {
        emojis: ".5em",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // require("@tailwindcss/typography"),
    // require("@tailwindcss/container-queries"),
  ],
}
