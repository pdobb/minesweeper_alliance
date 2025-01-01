import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import Mouse from "mouse"
import Touchpad from "touchpad"

export const mouse = (event) => new Mouse(event)
export const touchpad = (event) => new Touchpad(event)

// BoardController is responsible for managing clicks on Cells within the
// Game Board. All valid clicks event types result in a Turbo Stream "POST"
// being sent to the Rails server.
//
// For Mobile Browsers:
//   For Unrevealed Cells:
//    - Tap -> Reveal Cell
//    - Long Press -> Toggle Flag
//   For Revealed Cells
//    - Tap -> Reveal Neighbors
//
// For Non-Mobile Browsers:
//   For Unrevealed Cells:
//    - Left Click -> Reveal Cell
//    - Right Click -> Toggle Flag
//   For Revealed Cells
//    - Left Click (onMouseDown) -> Highlight Neighbors
//    - Left Click (onMouseUp) -> Reveal Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    if (mouse(event).isRightClick()) return this.toggleFlag(event)

    const $cell = event.target
    if (!($cell instanceof HTMLTableCellElement)) return
    if (this.#isRevealed($cell) || this.#isFlagged($cell)) return

    this.#submit($cell, this.revealUrlValue)
  }

  toggleFlag(event) {
    const $cell = event.target
    if (!this.#isFlaggable($cell)) return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  highlightNeighbors(event) {
    if (mouse(event).isNotLeftClick()) return

    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    this.#submit($cell, this.highlightNeighborsUrlValue)
  }

  revealNeighbors(event) {
    if (mouse(event).isNotLeftClick()) return

    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    this.#submit($cell, this.revealNeighborsUrlValue)
  }

  touchStart(event) {
    if (!this.#isFlaggable(event.target)) return

    this.longPressHandler = touchpad(event).handleLongPress(() => {
      this.#indicateSuccessfulToggleFlagEvent()
      this.toggleFlag(event)
    })
  }

  touchEnd() {
    this.longPressHandler?.cancel()
  }

  #isFlaggable($cell) {
    return $cell instanceof HTMLTableCellElement && !this.#isRevealed($cell)
  }

  #indicateSuccessfulToggleFlagEvent() {
    document
      .getElementById("flagsToMinesRatio")
      .classList.add("animate-ping-once")
    if (navigator.vibrate) navigator.vibrate(100)
  }

  #isRevealed($cell) {
    return $cell.dataset.revealed === "true"
  }

  #isNotRevealed($cell) {
    return $cell.dataset.revealed === "false"
  }

  #isFlagged($cell) {
    return $cell.dataset.flagged === "true"
  }

  #isBlank($cell) {
    return $cell.innerHTML.trim() === ""
  }

  #submit($cell, baseUrl) {
    this.#showLoadingIndicator($cell)

    const cellId = $cell.dataset.id
    // /boards/<boardId>/cells/<cellId>/<action>
    const targetUrl = baseUrl.replace(
      this.constructor.cellIdRegex,
      `cells/${cellId}/`,
    )

    post(targetUrl, { responseKind: "turbo-stream" })
  }

  #showLoadingIndicator($cell) {
    $cell.classList.add("animate-pulse-fast")
  }
}
