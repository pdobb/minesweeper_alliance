const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  darkMode: "class",
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,html,rb}",
    "./app/assets/images/**/*.svg",
    "./config/locales/*.yml",
  ],
  theme: {
    extend: {
      keyframes: {
        "ping-sm": { "75%, 100%": { transform: "scale(1.5)", opacity: "0" } },
      },
      animation: {
        "ping-once": "ping-sm 0.5s cubic-bezier(0, 0, 0.2, 1) 1",
        "pulse-fast": "pulse 1.5s cubic-bezier(0.6, 0, 0.4, 1) infinite",
      },
      backgroundImage: {
        "external-link-light": "url('heroicons/arrow-top-right-on-square.svg')",
        "external-link-dark":
          "url('heroicons/arrow-top-right-on-square-dark.svg')",
      },
      letterSpacing: {
        emojis: ".5em",
      },
      size: {
        5.5: "1.375em",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    function ({ addVariant }) {
      addVariant("light", "html:not(.dark) &")
    },
  ],
}
