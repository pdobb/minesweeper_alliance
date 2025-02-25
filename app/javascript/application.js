// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.USER_COOKIE = "user_token" // See {User::Current::COOKIE}.
window.THEME_COOKIE = "theme"
window.TIME_ZONE_COOKIE = "time_zone"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target)
}

Turbo.StreamActions.versioned_replace = function () {
  const currentVersion = parseFloat(this.targetElements[0].dataset.version)
  const payloadVersion = parseFloat(
    this.templateContent.children[0].dataset.version,
  )

  if (payloadVersion > currentVersion) Turbo.StreamActions.replace.call(this)
}
