import { Controller } from "@hotwired/stimulus"

// AutoSolveController toggle a simple auto-solve process that works only when
// the server is in DEBUG mode--which reveals mine Cells.
export default class extends Controller {
  static values = { delay: { type: Number, default: 100 } }

  static REVEALABLE_CELL_SELECTOR =
    'td[data-revealed="false"][data-flagged="false"]'
  static HIDDEN_MINE_SELECTOR = "td.bg-slate-500"
  static SAFELY_REVEALABLE_CELL_SELECTOR = `${this.REVEALABLE_CELL_SELECTOR}:not(${this.HIDDEN_MINE_SELECTOR})`
  static CELL_LOADING_SELECTOR = "td.animate-pulse-fast:not(.bg-slate-300)"

  connect() {
    this.table = document.querySelector("table")
    this.isSolving = false
    this.clickEvent = new MouseEvent("click", { bubbles: true })
  }

  toggleSolve() {
    if (this.isSolving) {
      this.#pause()
    } else {
      this.#startSolving()
    }
  }

  #startSolving() {
    this.isSolving = true
    this.#solve()
  }

  #pause() {
    this.isSolving = false
  }

  #solve() {
    if (!this.table || !this.isSolving) return

    if (this.#isLagging()) {
      this.#iterateAfterDelay()
    } else {
      this.unrevealedCells = this.#findUnrevealedCells()
      this.#clickRandomCell()
      this.#iterateAfterDelay()
    }
  }

  #isLagging() {
    return (
      this.table.querySelector(this.constructor.CELL_LOADING_SELECTOR) !== null
    )
  }

  #findUnrevealedCells() {
    return Array.from(
      this.table.querySelectorAll(
        this.constructor.SAFELY_REVEALABLE_CELL_SELECTOR,
      ),
    )
  }

  #clickRandomCell() {
    const randomCell =
      this.unrevealedCells[
        Math.floor(Math.random() * this.unrevealedCells.length)
      ]

    randomCell.dispatchEvent(this.clickEvent)
  }

  // Wait for the server to catch up.
  #iterateAfterDelay() {
    if (this.isSolving) setTimeout(() => this.#solve(), this.delayValue)
  }
}
