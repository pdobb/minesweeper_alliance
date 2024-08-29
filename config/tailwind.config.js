const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,html,rb}",
  ],
  theme: {
    extend: {
      animation: {
        "pulse-fast": "pulse 1.5s cubic-bezier(0.6, 0, 0.4, 1) infinite",
      },
      fontFamily: {
        // sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // require("@tailwindcss/typography"),
    // require("@tailwindcss/container-queries"),
  ],
}
