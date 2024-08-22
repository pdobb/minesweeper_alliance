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

    this.#submit($el, "reveal")
  }

  toggleFlag(event) {
    let $el = event.target
    if ($el.dataset.revealed === "true") return

    this.#submit($el, "toggleFlag")
  }

  revealNeighbors(event) {
    let $el = event.target
    if ($el.dataset.revealed === "false") return

    this.#submit($el, "revealNeighbors")
  }

  #submit($el, linkId) {
    $el.classList.add("animate-pulse")

    let $link = document.getElementById(linkId)
    let cellId = $el.dataset.id

    // /boards/<boardId>/cells/<cellId>/reveal
    $link.href = $link.href.replace(/cells\/(\d+)\//, `cells/${cellId}/`)

    $link.click()
  }
}
