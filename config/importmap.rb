# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "el-transition" # @0.0.7

# Utils
pin "cookies", to: "lib/cookies.js"
pin "mouse", to: "lib/mouse.js"
pin "parse_time", to: "lib/parse_time.js"
pin "touchpad", to: "lib/touchpad.js"
