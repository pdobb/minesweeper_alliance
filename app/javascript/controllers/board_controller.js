import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// BoardController is responsible for managing clicks on Cells within the
// Game Board.
//
// For Unrevealed Cells:
//  - Left Click - Reveal Cell
//  - Right Click - Toggle Flag
// For Revealed Cells
//  - Left Click (onMouseDown) - Highlight Neighbors
//  - Left Click (onMouseUp) - Reveal Neighbors
export default class extends Controller {
  static LEFT_MOUSE_BUTTON = 0

  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    const $cell = event.target
    if (!($cell instanceof HTMLTableCellElement)) return
    if (this.#isRevealed($cell) || this.#isFlagged($cell)) return

    this.#submit($cell, this.revealUrlValue)
  }

  toggleFlag(event) {
    const $cell = event.target
    if (this.#isRevealed($cell)) return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  highlightNeighbors(event) {
    if (event.button !== this.constructor.LEFT_MOUSE_BUTTON) return

    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    this.#submit($cell, this.highlightNeighborsUrlValue)
  }

  revealNeighbors(event) {
    if (event.button !== this.constructor.LEFT_MOUSE_BUTTON) return

    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    this.#submit($cell, this.revealNeighborsUrlValue)
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
