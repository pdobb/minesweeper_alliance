import { Controller } from "@hotwired/stimulus"

// DevPortal::DevOverlayController is responsible for revealing/collapsing the
// dev overlay at the bottom-right corner of the browser window while in the
// development env.
export default class extends Controller {
  static classes = ["collapse"]

  reveal() {
    this.element.classList.remove(...this.collapseClasses)
  }

  collapse() {
    this.element.classList.add(...this.collapseClasses)
  }
}
