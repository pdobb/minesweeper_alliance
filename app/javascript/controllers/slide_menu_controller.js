import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "el-transition"
import { cookies } from "cookies"

export default class extends Controller {
  static targets = ["menu", "openButton", "closeButton"]
  static values = {
    cookieName: String,
    openState: { type: String, default: "open" },
  }

  open() {
    this.#setCookie()
    enter(this.menuTarget).then(() => this.#hideOpenButton())

    this.menuTarget.setAttribute("aria-hidden", "false")
    this.openButtonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.#unsetCookie()
    leave(this.menuTarget).then(() => this.#showOpenButton())

    this.menuTarget.setAttribute("aria-hidden", "true")
    this.openButtonTarget.setAttribute("aria-expanded", "false")
  }

  #setCookie() {
    if (!this.hasCookieNameValue) return

    cookies.permanent.set(this.cookieNameValue, this.openStateValue)
  }

  #unsetCookie() {
    if (!this.hasCookieNameValue) return

    cookies.delete(this.cookieNameValue)
  }

  #hideOpenButton() {
    this.openButtonTarget.classList.add("hidden")
  }

  #showOpenButton() {
    this.openButtonTarget.classList.remove("hidden")
  }
}
