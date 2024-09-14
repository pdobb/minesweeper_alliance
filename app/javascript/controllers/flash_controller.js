import { Controller } from "@hotwired/stimulus"

// FlashController is responsible for managing Rails's Flash Notifications.
export default class extends Controller {
  static values = {
    timeout: { type: Number },
  }
  static classes = ["hide"]

  connect() {
    this.#setTimeout()
  }

  disconnect() {
    this.#clearTimeout()
  }

  close() {
    this.element.classList.add(...this.hideClasses)
  }

  remove() {
    this.element.remove()
  }

  #setTimeout() {
    if (this.timeoutValue > 0) {
      this.timeoutId = setTimeout(() => this.close(), this.timeoutValue)
    }
  }

  #clearTimeout() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }
}
