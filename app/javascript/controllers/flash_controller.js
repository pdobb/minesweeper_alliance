import { Controller } from "@hotwired/stimulus"

// FlashController is responsible for managing our front-end implementation of
// Rails's Flash Notifications.
export default class extends Controller {
  static values = {
    timeout: { type: Number },
  }
  static classes = ["hide"]

  connect() {
    this.#setAutoHideTimer()
  }

  disconnect() {
    this.#clearAutoHideTimer()
  }

  close() {
    this.element.classList.add(...this.hideClasses)
  }

  remove() {
    this.element.remove()
  }

  #setAutoHideTimer() {
    if (this.timeoutValue > 0) {
      this.autoHideTimer = setTimeout(() => this.close(), this.timeoutValue)
    }
  }

  #clearAutoHideTimer() {
    if (this.autoHideTimer) {
      clearTimeout(this.autoHideTimer)
      this.autoHideTimer = null
    }
  }
}
