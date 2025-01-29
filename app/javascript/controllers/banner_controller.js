import { Controller } from "@hotwired/stimulus"
import { cookies } from "cookies"

// BannerController is responsible for managing Application-level banner text.
// Banners are always dismissable, but will return on the next page visit
// unless the given `permanentlyDismissable` value is true.
export default class extends Controller {
  static values = {
    cookieName: String,
    permanentlyDismissable: Boolean,
    dismissal: { type: String, default: "dismissed" },
  }
  static classes = ["hide"]

  dismiss() {
    this.element.classList.add(...this.hideClasses)

    this.#saveDismissal()
  }

  remove() {
    this.element.remove()
  }

  #saveDismissal() {
    if (!this.permanentlyDismissableValue) return
    if (!this.hasCookieNameValue) return

    cookies.permanent.set(this.cookieNameValue, this.dismissalValue)
  }
}
