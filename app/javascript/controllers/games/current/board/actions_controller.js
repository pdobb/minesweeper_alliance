import { Controller } from "@hotwired/stimulus"
import { isMobile } from "touch"

// Games::Current::Board::ActionsController is responsible for managing clicks
// on Buttons that cause actions on the Game board. e.g. The "Reveal Random"
// button.
export default class extends Controller {
  static values = { boardId: String }

  static revealableCellsSelector = `td[data-revealed="false"][data-flagged="false"]`

  connect() {
    this.isMobile = isMobile()
  }

  // Clicking on the "Reveal Random" button randomly picks an eligible Table
  // Cell and calls `click()` on it.
  revealRandom(event) {
    event.target.disabled = true
    this.#submit(this.#getCellForRandomReveal())
    event.target.disabled = false
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

  #submit($cell) {
    // If e.g. all unrevealed Cells have been Flagged, #getCellForRandomReveal()
    // returns `null`.
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
