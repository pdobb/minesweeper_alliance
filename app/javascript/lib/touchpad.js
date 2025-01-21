export default class Touchpad {
  static LONG_PRESS_TIMEOUT = 250 // ms

  constructor(event) {
    this.event = event
  }

  onLongPress(callback) {
    if (this.isMultiTouch) return

    return window.setTimeout(callback, Touchpad.LONG_PRESS_TIMEOUT)
  }

  get isMultiTouch() {
    return !this.isSingleTouch
  }

  get isSingleTouch() {
    return this.event.touches?.length === 1
  }
}
