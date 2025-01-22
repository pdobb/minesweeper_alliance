import { post } from "@rails/request.js"

// Games::Current::Board::Cell wraps a Table Cell element for querying on its
// state. It also exposes the Cell actions:
//   - Reveal
//   - Toggle Flag
//   - Highlight Neighbors
//   - Reveal Neighbors
class Cell {
  static domIdRegex = /^cell_/
  static cellIdUrlRegex = /cells\/(\d+)\//

  constructor(element) {
    this.element = element
  }

  highlightNeighbors(url) {
    if (this.isNotRevealed || this.isBlank) return

    this.#submit(url)
  }

  toggleFlag(url, beforeSubmit = () => {}) {
    if (this.isNotFlaggable) return

    beforeSubmit()
    this.#submit(url)
  }

  revealNeighbors(url) {
    if (this.isNotRevealed || this.isBlank) return

    this.#submit(url)
  }

  reveal(url) {
    if (this.isNotTableCell) return
    if (this.isRevealed || this.isFlagged) return

    this.#submit(url)
  }

  get id() {
    return this.element.id.replace(Cell.domIdRegex, "")
  }

  get isRevealed() {
    return this.element.dataset.revealed === "true"
  }
  get isNotRevealed() {
    return this.element.dataset.revealed === "false"
  }

  get isFlaggable() {
    return this.isNotRevealed
  }
  get isNotFlaggable() {
    return !this.isFlaggable
  }

  get isFlagged() {
    return this.element.dataset.flagged === "true"
  }

  get isBlank() {
    return this.element.innerHTML.trim() === ""
  }

  get isTableCell() {
    return this.element instanceof HTMLTableCellElement
  }
  get isNotTableCell() {
    return !this.isTableCell
  }

  #submit(baseUrl) {
    this.#showLoadingIndicator()

    // /games/<game_id>/board/cells/<cell_id>/<action>
    const targetUrl = baseUrl.replace(Cell.cellIdUrlRegex, `cells/${this.id}/`)

    post(targetUrl, { responseKind: "turbo-stream" })
  }

  #showLoadingIndicator() {
    this.element.classList.add("animate-pulse-fast")
  }
}

export const cell = (element) => new Cell(element)
