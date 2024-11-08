import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

// DisplayCaseController represents a dynamically shown/hideable view "frame"
// (e.g. a <div> with a border).
export default class extends Controller {
  static targets = ["turboFrame"]

  static SHOWING_STATE = "showing"
  static VISIBLE_STATE = "visible"
  static HIDING_STATE = "hiding"
  static EMPTY_STATE = "empty"

  load() {
    if (this.#isEmpty()) {
      // Loading new content.
      this.show()
    } else if (this.#isVisible()) {
      // Just changing source content.
      this.dispatch("show")
    } else {
      // Hiding
    }
  }

  show() {
    this.#setState(this.constructor.SHOWING_STATE)

    enter(this.element).then(() => {
      this.#setState(this.constructor.VISIBLE_STATE)
      this.dispatch("show")
    })
  }

  hide(event) {
    this.#setState(this.constructor.HIDING_STATE)

    event.currentTarget.blur()

    leave(this.element).then(() => {
      this.#empty()
      this.#setState(this.constructor.EMPTY_STATE)
      this.dispatch("hide")
    })
  }

  #empty() {
    this.turboFrameTarget.replaceChildren()
  }

  #isEmpty() {
    return this.#getState() == this.constructor.EMPTY_STATE
  }

  #isVisible() {
    return this.#getState() == this.constructor.VISIBLE_STATE
  }

  #getState() {
    return this.turboFrameTarget.dataset.state
  }

  #setState(value) {
    this.turboFrameTarget.dataset.state = value
  }
}
