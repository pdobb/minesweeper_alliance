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
  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "true") return

    this.#submit($cell, "reveal")
  }

  toggleFlag(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "true") return

    this.#submit($cell, "toggleFlag")
  }

  revealNeighbors(event) {
    const $cell = event.target
    if ($cell.dataset.revealed === "false") return

    this.#submit($cell, "revealNeighbors")
  }

  // This event comes from clicking the "Reveal a Random Cell" button, and not
  // from clicking on a Cell itself. But we still want to show the same "Cell
  // loading" indicator, in case of a pop.
  revealRandom(event) {
    const $button = event.target
    const cellId = $button.href.match(this.constructor.cellIdRegex)?.[1]
    const $cell = document.querySelector(`td[data-id="${cellId}"]`)
    this.#showLoadingIndicator($cell)
  }

  #submit($cell, linkId) {
    this.#showLoadingIndicator($cell)

    const $link = document.getElementById(linkId)
    const cellId = $cell.dataset.id

    // /boards/<boardId>/cells/<cellId>/reveal
    $link.href = $link.href.replace(
      this.constructor.cellIdRegex,
      `cells/${cellId}/`,
    )

    $link.click()
  }

  #showLoadingIndicator($cell) {
    $cell.classList.add("animate-pulse")
  }
}
