import { Controller } from "@hotwired/stimulus"
import { cell } from "games/current/board/cell"
import { mouse } from "mouse"
import { touch, isMobile } from "touch"
import { animateOnce } from "effects"

// Games::Current::BoardController is responsible for managing clicks on Cells
// within the the Game Board (for both mobile and desktop browsers). All valid
// clicks/taps result in a Turbo Stream "POST" request being sent to the server.
//
// Desktop:
//  For Unrevealed Cells:
//   - Left Click -> Reveal Cell
//   - Right Click -> Toggle Flag
//  For Revealed Cells
//   - Left Click (onMouseDown) -> Highlight Neighbors
//   - Left Click (onClick) -> Reveal/Dehighlight Neighbors
//
// Mobile:
//   For Unrevealed Cells:
//    - Tap -> Reveal Cell
//    - Long Press -> Toggle Flag
//   For Revealed Cells
//    - Tap -> Reveal Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    dehighlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  connect() {
    this.isMobile = isMobile()
    this.isDesktop = !this.isMobile
  }

  // Desktop Events

  dispatchMousedown(event) {
    if (this.isMobile) return
    if (!mouse(event).actsAsLeftClick()) return

    this.mousedownTarget = event.target

    cell(event.target).highlightNeighbors(this.highlightNeighborsUrlValue)
  }

  dispatchMouseup(event) {
    if (this.isMobile) return
    if (!this.mousedownTarget || mouse(event).actsAsRightClick()) return

    if (event.target != this.mousedownTarget) {
      cell(this.mousedownTarget).dehighlightNeighbors(
        this.dehighlightNeighborsUrlValue,
      )
    }

    this.mousedownTarget = null
  }

  dispatchContextmenu(event) {
    if (this.isMobile) return
    cell(event.target).toggleFlag(this.toggleFlagUrlValue)
  }

  dispatchClick(event) {
    if (this.isMobile) return
    if (mouse(event).actsAsRightClick()) return

    const $cell = cell(event.target)

    if ($cell.isRevealed) {
      $cell.revealNeighbors(this.revealNeighborsUrlValue)
    } else {
      $cell.reveal(this.revealUrlValue)
    }
  }

  // Mobile Events

  dispatchTouchStart(event) {
    if (this.isDesktop) return
    this.longPressExecuted = this.touchMoveDetected = false

    cell(event.target).highlightNeighbors(this.highlightNeighborsUrlValue)

    this.longPressTimer = touch(event).onLongPress(() => {
      this.longPressExecuted = true
      this.#longPress(event)
    })
  }

  dispatchTouchMove() {
    if (this.isDesktop) return
    this.touchMoveDetected = true
    clearTimeout(this.longPressTimer)
  }

  dispatchTouchEnd(event) {
    if (this.isDesktop) return
    if (this.touchMoveDetected || this.longPressExecuted) {
      cell(event.target).dehighlightNeighbors(this.dehighlightNeighborsUrlValue)
      return
    }

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
