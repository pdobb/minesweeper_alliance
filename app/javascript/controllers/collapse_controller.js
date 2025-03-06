import { Controller } from "@hotwired/stimulus"
import { toggle } from "el-transition"
import { cookies } from "cookies"

export default class extends Controller {
  static targets = ["button", "content"]
  static values = {
    cookieName: String,
    collapsedState: { type: String, default: "collapsed" },
  }
  static classes = ["open"]

  toggle() {
    if (this.hasCookieNameValue) this.#setCookie()
    this.#toggleOpenState()
    toggle(this.contentTarget)
    this.#toggleAriaAttributes()
  }

  #setCookie() {
    if (this.#isOpen) {
      cookies.permanent.set(this.cookieNameValue, this.collapsedStateValue)
    } else {
      cookies.delete(this.cookieNameValue)
    }
  }

  get #isOpen() {
    return this.element.classList.contains(this.openClass)
  }

  #toggleOpenState() {
    this.element.classList.toggle(this.openClass)
  }

  #toggleAriaAttributes() {
    if (this.#isOpen) {
      this.contentTarget.setAttribute("aria-hidden", "true")
      this.buttonTarget.setAttribute("aria-expanded", "false")
    } else {
      this.contentTarget.setAttribute("aria-hidden", "false")
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }
  }
}
