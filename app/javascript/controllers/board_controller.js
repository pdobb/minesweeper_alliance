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
  static LEFT_MOUSE_BUTTON = 0

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
      (match, capture_group) => {
        return match.replace(capture_group, cellId)
      },
    )

    this.#updateBoardActionProxyTarget(targetUrl).requestSubmit()
  }

  #updateBoardActionProxyTarget(targetUrl) {
    const $boardActionProxy = document.getElementById(this.actionProxyIdValue)
    $boardActionProxy.action = targetUrl

    const $authenticityToken = $boardActionProxy.querySelector(
      'input[type="hidden"][name="authenticity_token"]',
    )
    const csrfToken = document.head.querySelector(
      "meta[name=csrf-token]",
    ).content
    $authenticityToken.value = csrfToken

    return $boardActionProxy
  }

  #showLoadingIndicator($cell) {
    $cell.classList.add("animate-pulse-fast")
  }
}
