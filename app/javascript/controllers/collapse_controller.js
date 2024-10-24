import { Controller } from "@hotwired/stimulus"
import { toggle } from "el-transition"
import { cookies } from "cookies"

export default class extends Controller {
  static targets = ["button", "icon", "section"]
  static values = {
    cookieName: String,
    collapsedState: { type: String, default: "collapsed" },
  }
  static classes = ["buttonToggle", "iconToggle"]

  toggle() {
    this.#setCookie()
    this.toggleButtonState()
    toggle(this.sectionTarget)
    this.#updateAriaAttributes()
  }

  #setCookie() {
    if (!this.hasCookieNameValue) return

    if (this.#sectionIsHidden()) {
      // -> Visible
      cookies.delete(this.cookieNameValue)
    } else {
      // -> Hidden
      cookies.permanent.set(this.cookieNameValue, this.collapsedStateValue)
    }
  }

  #sectionIsHidden() {
    return this.sectionTarget.classList.contains("hidden")
  }

  toggleButtonState() {
    this.buttonTarget.classList.toggle(this.buttonToggleClass)
    this.iconTarget.classList.toggle(this.iconToggleClass)
  }

  #updateAriaAttributes() {
    if (this.sectionTarget.getAttribute("aria-hidden") === "true") {
      this.sectionTarget.setAttribute("aria-hidden", "false")
      this.buttonTarget.setAttribute("aria-expanded", "true")
    } else {
      this.sectionTarget.setAttribute("aria-hidden", "true")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }
}
