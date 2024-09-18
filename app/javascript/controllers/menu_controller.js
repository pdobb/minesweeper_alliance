import { Controller } from "@hotwired/stimulus"
import { enter, leave, toggle } from "el-transition"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    toggle(this.menuTarget)
    this.toggleButtonState()
    this.#updateAriaAttributes()
  }

  escape() {
    this.#hide()
  }

  cancel(event) {
    if (this.#isExternal(event.target) || this.#isLinkInMenu(event.target)) {
      this.#hide()
    }
  }

  toggleButtonState() {
    // Implement in child classes as needed.
  }

  #show() {
    if (this.#menuIsHidden()) {
      enter(this.menuTarget)
      this.toggleButtonState()
      this.#updateAriaAttributes()
    }
  }

  #hide() {
    if (this.#menuIsVisible()) {
      leave(this.menuTarget)
      this.toggleButtonState()
      this.#updateAriaAttributes()
    }
  }

  #menuIsHidden() {
    return this.menuTarget.classList.contains("hidden")
  }

  #menuIsVisible() {
    return !this.#menuIsHidden()
  }

  #isExternal(target) {
    return !this.#isInternal(target)
  }

  #isInternal(target) {
    return this.buttonTarget.contains(target) || this.#isInMenu(target)
  }

  #isLinkInMenu(target) {
    return this.#isInMenu(target) && this.#isLink(target)
  }

  #isInMenu(target) {
    return (
      this.menuTarget.contains(target) && !target.hasAttribute("data-external")
    )
  }

  #isLink(target) {
    if (target instanceof HTMLAnchorElement) return true

    return target.getAttribute("data-action")?.startsWith("click->") || false
  }

  #updateAriaAttributes() {
    if (this.menuTarget.getAttribute("aria-hidden") === "true") {
      this.menuTarget.setAttribute("aria-hidden", "false")
      this.buttonTarget.setAttribute("aria-expanded", "true")
    } else {
      this.menuTarget.setAttribute("aria-hidden", "true")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }
}
