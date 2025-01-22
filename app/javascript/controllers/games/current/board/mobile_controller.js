import { Controller } from "@hotwired/stimulus"
import { cell } from "games/current/board/cell"
import { touch } from "touch"
import { animateOnce } from "effects"

// Games::Current::Board::MobileController is responsible for managing taps on
// Cells within the mobile Game Board. All valid taps result in a Turbo
// Stream "POST" request being sent to the server.
//
// For Unrevealed Cells:
//  - Tap -> Reveal Cell
//  - Long Press -> Toggle Flag
// For Revealed Cells
//  - Tap -> Reveal Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    revealNeighborsUrl: String,
  }

  dispatchTouchStart(event) {
    this.longPressExecuted = this.touchMoveDetected = false

    this.longPressTimer = touch(event).onLongPress(() => {
      this.longPressExecuted = true
      this.#longPress(event)
    })
  }

  dispatchTouchMove() {
    this.touchMoveDetected = true
    clearTimeout(this.longPressTimer)
  }

  dispatchTouchEnd(event) {
    if (this.touchMoveDetected || this.longPressExecuted) return

    clearTimeout(this.longPressTimer)
    this.#tap(event)
  }

  #tap(event) {
    const $cell = cell(event.target)

    if ($cell.isRevealed) $cell.revealNeighbors(this.revealNeighborsUrlValue)
    else $cell.reveal(this.revealUrlValue)
  }

  #longPress(event) {
    cell(event.target).toggleFlag(
      this.toggleFlagUrlValue,
      this.#indicateSuccessfulToggleFlagEvent,
    )
  }

  #indicateSuccessfulToggleFlagEvent() {
    animateOnce(
      document.getElementById("flagsToMinesRatio"),
      "animate-ping-once",
    )

    if (navigator.vibrate) navigator.vibrate(100)
  }
}
