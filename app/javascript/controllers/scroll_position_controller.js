import { Controller } from "@hotwired/stimulus"

// ScrollPositionController is responsible for saving the current
// horizontal/vertical scroll position for `this.element` and then, restoring
// it--e.g. after replacement via turbo stream.
//
// Current values are saved into the storage element's dataset. The storage
// element is identified by ID, as passed-in by
// `data-scroll-position-storage-element-id-value`.
//
// Values are restored on `connect` for this controller.
//
// For this to work, the storage element is expected to exist outside of
// `this.element` or its dataset (and, thus, our data store) be wiped out.
export default class extends Controller {
  static values = { storageElementId: String }

  connect() {
    this.storage =
      document.getElementById(this.storageElementIdValue)?.dataset || {}
    this.#restore()
  }

  save() {
    this.scrollLeft = this.element.scrollLeft
    this.scrollTop = this.element.scrollTop
  }

  #restore() {
    if (this.scrollLeft) this.element.scrollLeft = parseFloat(this.scrollLeft)
    if (this.scrollTop) this.element.scrollTop = parseFloat(this.scrollTop)
  }

  get scrollLeft() {
    return this.storage.scrollLeft
  }
  set scrollLeft(value) {
    this.storage.scrollLeft = value
  }

  get scrollTop() {
    return this.storage.scrollTop
  }
  set scrollTop(value) {
    this.storage.scrollTop = value
  }
}
