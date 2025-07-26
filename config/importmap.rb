# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin "games/current/board/cell", to: "controllers/games/current/board/cell.js"

# /lib

pin "cookies", to: "lib/cookies.js"
pin "effects", to: "lib/effects.js"
pin "mouse", to: "lib/mouse.js"
pin "parse_time", to: "lib/parse_time.js"
pin "touch", to: "lib/touch.js"

# External libraries

pin "el-transition" # @0.0.7
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.7.3
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.7.3
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.10
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js"
