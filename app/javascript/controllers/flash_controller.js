import { Controller } from "@hotwired/stimulus"
import { leave } from "el-transition"

// FlashController is responsible for managing our front-end implementation of
// Rails's Flash Notifications.
export default class extends Controller {
  static values = {
    timeout: { type: Number },
  }

  connect() {
    this.#setAutoHideTimer()
  }

  disconnect() {
    this.#clearAutoHideTimer()
  }

  close() {
    leave(this.element).then(() => {
      this.element.remove()
    })
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
