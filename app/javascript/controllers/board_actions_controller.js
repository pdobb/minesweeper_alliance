import { Controller } from "@hotwired/stimulus"

// BoardActionsController is responsible for managing clicks on Buttons that
// cause actions on the Game board. e.g. The "Reveal Random" button.
export default class extends Controller {
  static values = { boardId: String }

  static revealableCellsSelector =
    'td:not([data-revealed="true"]):not([data-flagged="true"])'

  // "Reveal Random" button.
  revealRandom(event) {
    event.currentTarget.disabled = true
    this.#getCellForRandomReveal().click()
  }

  #getCellForRandomReveal() {
    const $cells = this.#getCells()
    const randomIndex = Math.floor(Math.random() * $cells.length)

    return $cells[randomIndex]
  }

  #getCells() {
    const $board = this.#getBoard()
    return $board.querySelectorAll(this.constructor.revealableCellsSelector)
  }

  #getBoard() {
    return document.getElementById(this.boardIdValue)
  }
}
