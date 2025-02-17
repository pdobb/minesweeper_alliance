// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.USER_COOKIE = "user_token" // See {User::Current::COOKIE}.
window.THEME_COOKIE = "theme"
window.TIME_ZONE_COOKIE = "time_zone"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target)
}
