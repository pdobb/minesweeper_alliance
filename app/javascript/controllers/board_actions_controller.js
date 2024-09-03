import { Controller } from "@hotwired/stimulus"

// BoardActionsController is responsible for managing clicks on Buttons that
// cause actions on the Game board. e.g. The "Reveal Random" button.
export default class extends Controller {
  static values = { boardId: String }

  // "Reveal Random" button.
  revealRandom(event) {
    event.currentTarget.disabled = true
    this.#getCellForRandomReveal().click()
  }

  #getCellForRandomReveal() {
    const $cellsContainer = document.getElementById(this.boardIdValue)
    const cellsQuery = $cellsContainer.querySelectorAll(
      'td:not([data-revealed="true"]):not([data-flagged="true"])',
    )
    const randomIndex = Math.floor(Math.random() * cellsQuery.length)
    return cellsQuery[randomIndex]
  }
}
