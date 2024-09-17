import { Controller } from "@hotwired/stimulus"

// BannerController is responsible for managing Site-level banner text. i.e.
// informational text that, once dismissed, doesn't reappear in the future.
export default class extends Controller {
  static classes = ["hide"]

  close() {
    this.element.classList.add(...this.hideClasses)
  }

  remove() {
    this.element.remove()
  }
}
