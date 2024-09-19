import { Controller } from "@hotwired/stimulus"
import { cookies } from "../lib/cookies"

// BannerController is responsible for managing Application-level banner text.
// i.e. informational text that, once dismissed, doesn't reappear in the future.
// Or, if permanent dismissal isn't desired, then we just won't receive a
// `nameValue`.
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

    cookies.permanent.set(this.nameValue, this.dismissalValue, { secure: true })
  }
}
