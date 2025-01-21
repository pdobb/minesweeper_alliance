// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.versioned_replace = function () {
  const currentVersion = parseFloat(this.targetElements[0].dataset.version)
  const payloadVersion = parseFloat(
    this.templateContent.children[0].dataset.version,
  )

  if (payloadVersion > currentVersion) Turbo.StreamActions.replace.call(this)
}

// Performs a wholesale replacement of the targets with the given CSS classes.
Turbo.StreamActions.replace_css = function () {
  const value = this.getAttribute("css")

  this.targetElements.forEach((cell) => {
    cell.className = value
  })
}
