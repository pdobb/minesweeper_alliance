import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// PatternController is responsible for managing clicks on Cells within a
// Pattern's Grid.
//
// Events:
//  - Left Click - Toggle Flag
export default class extends Controller {
  static values = {
    toggleFlagUrl: String,
  }

  toggleFlag(event) {
    const $cell = event.target
    if (!($cell instanceof HTMLTableCellElement)) return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  #submit($cell, baseUrl) {
    this.#showLoadingIndicator($cell)

    const coordinates = $cell.dataset.coordinates

    post(baseUrl, {
      responseKind: "turbo-stream",
      body: coordinates,
    })
  }

  #showLoadingIndicator($cell) {
    $cell.classList.add("animate-pulse-fast")
  }
}
