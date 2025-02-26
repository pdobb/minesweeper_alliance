import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 100 } }

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
    return this.table.querySelector(".animate-pulse-fast") !== null
  }

  #findUnrevealedCells() {
    return Array.from(
      this.table.querySelectorAll(
        'td[data-revealed="false"][data-flagged="false"]:not(.bg-slate-500)',
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

  #iterateAfterDelay() {
    let delay = this.delayValue
    if (this.unrevealedCells.length <= 2) delay *= 2

    if (this.isSolving) setTimeout(() => this.#solve(), delay)
  }
}
