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
  reveal(event) {
    let $el = event.target
    if ($el.dataset.revealed === "true") return

    this.#submitVia("reveal", $el.dataset.id)
  }

  toggleFlag(event) {
    let $el = event.target
    if ($el.dataset.revealed === "true") return

    this.#submitVia("toggleFlag", $el.dataset.id)
  }

  revealNeighbors(event) {
    let $el = event.target
    if ($el.dataset.revealed === "false") return

    this.#submitVia("revealNeighbors", $el.dataset.id)
  }

  #submitVia(linkId, cellId) {
    let $link = document.getElementById(linkId)

    // /boards/<boardId>/cells/<cellId>/reveal
    $link.href = $link.href.replace(/cells\/(\d+)\//, `cells/${cellId}/`)

    $link.click()
  }
}
