import { post } from "@rails/request.js"

// Games::Current::Board::Cell wraps a Table Cell element for querying on its
// state. It connects the front-end Cell Actions to their back-end counterparts:
//  - Reveal
//  - Toggle Flag
//  - Highlight Neighbors
//  - Reveal Neighbors
class Cell {
  static domIdRegex = /^cell_/
  static cellIdUrlRegex = /cells\/(\d+)\//
  static loadingIndicatorClass = "animate-pulse-fast"
  static warningIndicatorClasses = [
    "light:text-black",
    "bg-orange-500",
    "dark:bg-orange-700",
  ]
  static errorIndicatorClasses = ["bg-red-600", "dark:bg-red-900"]

  constructor(element) {
    this.element = element
  }

  highlightNeighbors(url) {
    if (this.isNotRevealed || this.isBlank) return

    this.#submit(url)
  }

  dehighlightNeighbors(url) {
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

    post(targetUrl, { responseKind: "turbo-stream" }).then((response) => {
      this.#hideLoadingIndicator()

      if (!response.ok) this.#handleSubmitError(response)
    })
  }

  #showLoadingIndicator() {
    this.element.classList.add(Cell.loadingIndicatorClass)
  }

  #hideLoadingIndicator() {
    this.element.classList.remove(Cell.loadingIndicatorClass)
  }

  #handleSubmitError(response) {
    switch (response.statusCode) {
      // TooManyRequests (from our Rate Limiter on Cell Actions)
      case 429:
        this.#showWarningIndicator()
        break
      default:
        this.#showErrorIndicator()
        Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  #showWarningIndicator(duration = 500) {
    clearTimeout(this.warningIndicatorTimer)

    this.element.classList.add(...Cell.warningIndicatorClasses)

    this.warningIndicatorTimer = setTimeout(() => {
      this.element.classList.remove(...Cell.warningIndicatorClasses)
    }, duration)
  }

  #showErrorIndicator() {
    this.element.classList.add(...Cell.errorIndicatorClasses)
  }
}

export const cell = (element) => new Cell(element)
