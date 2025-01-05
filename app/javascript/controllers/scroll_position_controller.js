import { Controller } from "@hotwired/stimulus"

// ScrollPositionController is responsible for saving the current
// horizontal/vertical scroll position for `this.element` and then restoring it
// after replacement via turbo stream.
//
// Current values are saved into the storage element's dataset. The storage
// element is identified by ID, as passed-in by
// `data-scroll-position-storage-element-id-value`.
//
// Values are restored after this element is replaced/re-connected.
//
// For this to work, the storage element is expected to exist outside of
// `this.element` or its dataset (and, thus, our data store) be wiped out.
export default class extends Controller {
  static values = { storageElementId: String }

  connect() {
    this.#restore()
  }

  save() {
    this.storage.scrollLeft = this.element.scrollLeft
    this.storage.scrollTop = this.element.scrollTop
  }

  #restore() {
    if (this.storage.scrollLeft) {
      this.element.scrollLeft = parseFloat(this.storage.scrollLeft)
    }
    if (this.storage.scrollTop) {
      this.element.scrollTop = parseFloat(this.storage.scrollTop)
    }
  }

  get storage() {
    return document.getElementById(this.storageElementIdValue)?.dataset || {}
  }
}
