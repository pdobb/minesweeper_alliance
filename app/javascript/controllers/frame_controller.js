import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

// FrameController represents a dynamically shown/hideable view frame.
export default class extends Controller {
  static targets = ["frame"]

  show() {
    if (!this.frameTarget.hasChildNodes()) return
    if (!this.element.classList.contains("hidden")) return

    enter(this.element)
  }

  hide(event) {
    event.currentTarget.blur()

    leave(this.element).then(() => {
      this.#empty()
      this.dispatch("hide")
    })
  }

  #empty() {
    this.frameTarget.replaceChildren()
  }
}
