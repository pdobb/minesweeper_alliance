import { Controller } from "@hotwired/stimulus"
import { isMobile } from "touch"

// Games::Current::Board::ActionsController is responsible for managing clicks
// on Buttons that cause actions on the Game board. e.g. The "Reveal Random"
// button.
export default class extends Controller {
  static values = { boardId: String }

  static REVEALABLE_CELL_SELECTOR =
    'td[data-revealed="false"][data-flagged="false"]'

  connect() {
    this.isMobile = isMobile()
  }

  // Clicking on the "Reveal Random" button randomly picks an eligible Table
  // Cell and calls `click()` on it.
  revealRandom(event) {
    event.target.disabled = true
    this.#submit(this.#getRandomUnrevealedCell())
    event.target.disabled = false
  }

  #getRandomUnrevealedCell() {
    const cells = this.#unrevealedCells
    const randomIndex = Math.floor(Math.random() * cells.length)

    return cells[randomIndex]
  }

  get #unrevealedCells() {
    return this.#board.querySelectorAll(
      this.constructor.REVEALABLE_CELL_SELECTOR,
    )
  }

  get #board() {
    return document.getElementById(this.boardIdValue)
  }

  #submit($cell) {
    // If e.g. all unrevealed Cells have been Flagged,
    // #getRandomUnrevealedCell() returns `null`.
    if (!$cell) return

    if (this.isMobile) {
      // We first have to clear out the longPressExecuted and touchMoveDetected
      // instance variables via touchstart in order for touchend to work
      // properly. :/
      $cell.dispatchEvent(new Event("touchstart", { bubbles: true }))
      $cell.dispatchEvent(new Event("touchend", { bubbles: true }))
    } else {
      $cell.click()
    }
  }
}
