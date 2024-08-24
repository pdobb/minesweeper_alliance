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
    revealNeighborsUrl: String,
  }
  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "true") return

    this.#submit($cell, this.revealUrlValue)
  }

  toggleFlag(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "true") return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  revealNeighbors(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "false") return

    this.#submit($cell, this.revealNeighborsUrlValue)
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
