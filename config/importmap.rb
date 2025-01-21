# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin "cookies", to: "lib/cookies.js"
pin "parse_time", to: "lib/parse_time.js"
pin "mouse", to: "lib/mouse.js"
pin "touch", to: "lib/touch.js"

pin_all_from "app/javascript/controllers", under: "controllers"

pin "el-transition" # @0.0.7
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.6.13
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.6.9
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.9
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js" # @0.2.9
