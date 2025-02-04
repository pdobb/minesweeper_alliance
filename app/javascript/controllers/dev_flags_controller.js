import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 100 } }

  connect() {
    this.table = document.querySelector("table")
    this.isSolving = false
    this.firstIteration = true
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
      this.#wait()
    } else {
      this.#clickRandomCell()
    }
  }

  #isLagging() {
    return this.table.querySelector(".animate-pulse-fast") !== null
  }

  #clickRandomCell() {
    const cells = this.#findRandomCell()
    const randomCell = cells[Math.floor(Math.random() * cells.length)]

    randomCell.dispatchEvent(new MouseEvent("click", { bubbles: true }))

    this.#wait()
  }

  #findRandomCell() {
    return Array.from(
      this.table.querySelectorAll(
        'td[data-revealed="false"][data-flagged="false"]:not(.bg-slate-500)',
      ),
    )
  }

  #wait() {
    const cells = this.#findRandomCell()
    let delay = this.delayValue

    if (this.firstIteration) {
      this.firstIteration = false
      delay = 200
    } else if (cells.length <= 2) {
      delay = 200
    }

    if (this.isSolving) setTimeout(() => this.#solve(), delay)
  }
}
