import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"

export default class extends Controller {
  static targets = ["menu", "openButton", "closeButton"]

  open() {
    enter(this.menuTarget).then(() => {
      this.#toggleOpenButton()
    })

    this.menuTarget.setAttribute("aria-hidden", "false")
    this.openButtonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    leave(this.menuTarget).then(() => {
      this.#toggleOpenButton()
    })

    this.menuTarget.setAttribute("aria-hidden", "true")
    this.openButtonTarget.setAttribute("aria-expanded", "false")
  }

  #toggleOpenButton() {
    this.openButtonTarget.classList.toggle("hidden")
  }
}
