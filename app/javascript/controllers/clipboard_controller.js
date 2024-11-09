import { Controller } from "@hotwired/stimulus"

// ClipboardController is responsible for copying a given source value to the
// user's clipboard.
export default class extends Controller {
  static values = { source: String }
  static classes = ["highlight"]

  copy(event) {
    navigator.clipboard.writeText(this.sourceValue).then(() => {
      event.target.classList.add(...this.highlightClasses)
    })
  }

  dehighlight(event) {
    event.target.classList.remove(...this.highlightClasses)
  }
}
