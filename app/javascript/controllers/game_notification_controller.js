import { Controller } from "@hotwired/stimulus"

// GameNotificationController is responsible for a singleton flash-style
// notification overlay that may appear on a Game Show page, specifically.
export default class extends Controller {
  static classes = ["hide"]

  close() {
    this.element.classList.add(...this.hideClasses)
  }

  remove() {
    this.element.remove()
  }
}
