import { Controller } from "@hotwired/stimulus"
import { cookies } from "cookies"

// BannerController is responsible for managing Application-level banner text.
// Banners are always dismissable, but will return on the next page visit
// unless the given `permanentlyDismissable` value is true.
export default class extends Controller {
  static values = {
    name: String,
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
    if (!this.hasNameValue) return

    cookies.permanent.set(this.nameValue, this.dismissalValue)
  }
}
