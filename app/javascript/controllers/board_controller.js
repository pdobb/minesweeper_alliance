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
    let $el = event.toElement
    if ($el.dataset.revealed === "true") return

    this.#post(`/cells/${$el.dataset.id}/reveal`)
  }

  toggleFlag(event) {
    let $el = event.toElement
    if ($el.dataset.revealed === "true") return

    this.#post(`/cells/${$el.dataset.id}/toggle_flag`)
  }

  revealNeighbors(event) {
    let $el = event.toElement
    if ($el.dataset.revealed === "false") return

    this.#post(`/cells/${$el.dataset.id}/reveal_neighbors`)
  }

  #post(url) {
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.#csrfToken(),
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        Accept: "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
      },
    })
      .then((response) => response.text())
      .then((html) => {
        document.documentElement.innerHTML = html
      })
  }

  #csrfToken() {
    return document
      .querySelector("meta[name='csrf-token']")
      .getAttribute("content")
  }
}
