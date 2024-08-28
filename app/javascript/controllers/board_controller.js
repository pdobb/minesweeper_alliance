import { Controller } from "@hotwired/stimulus"

// BoardController is responsible for managing clicks on Cells within the
// Game Board.
//
// For Unrevealed Cells:
//  - Left Click - Reveal Cell
//  - Right Click - Toggle Flag
// For Revealed Cells
//  - Double Click - Reveal Neighbors
export default class extends Controller {
  static values = {
    actionProxyId: String,
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }
  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    const $cell = event.target
    if (this.#isRevealed($cell) || this.#isFlagged($cell)) return

    this.#submit($cell, this.revealUrlValue)
  }

  toggleFlag(event) {
    const $cell = event.target
    if (this.#isRevealed($cell)) return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  highlightNeighbors(event) {
    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    this.#submit($cell, this.highlightNeighborsUrlValue)
  }

  revealNeighbors(event) {
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

    const $boardActionProxy = document.getElementById(this.actionProxyIdValue)
    const cellId = $cell.dataset.id

    // /boards/<boardId>/cells/<cellId>/<action>
    $boardActionProxy.href = baseUrl.replace(
      this.constructor.cellIdRegex,
      `cells/${cellId}/`,
    )

    $boardActionProxy.click()
  }

  #showLoadingIndicator($cell) {
    $cell.classList.add("animate-pulse")
  }
}
