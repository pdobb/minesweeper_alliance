import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { domId: String }
  static classes = ["connected", "disconnected"]

  connect() {
    this.observer = new MutationObserver(this.#displayCurrentState.bind(this))
    this.#observeStreamElement()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  get streamElement() {
    if (!this._streamElement) {
      this._streamElement = document.getElementById(this.domIdValue)
    }
    return this._streamElement
  }

  #observeStreamElement() {
    if (!this.streamElement) return

    this.observer.observe(this.streamElement, {
      attributes: true,
      attributeFilter: ["connected"],
    })
  }

  #displayCurrentState() {
    if (this.#isConnected()) {
      this.#displayConnectedState()
    } else {
      this.#displayDisconnectedState()
    }
  }

  #isConnected() {
    return this.streamElement?.hasAttribute("connected")
  }

  #displayConnectedState() {
    this.element.classList.add(this.connectedClass)
    this.element.classList.remove(this.disconnectedClass)
  }

  #displayDisconnectedState() {
    this.element.classList.add(this.disconnectedClass)
    this.element.classList.remove(this.connectedClass)
  }
}
