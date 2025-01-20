export default class Touchpad {
  static LONG_PRESS_TIMEOUT = 250 // ms

  constructor(event) {
    this.event = event
  }

  handleLongPress(onLongPress) {
    if (this.isMultiTouch) return { cancel: () => {} }

    const timer = window.setTimeout(onLongPress, Touchpad.LONG_PRESS_TIMEOUT)
    return { cancel: () => clearTimeout(timer) }
  }

  get isMultiTouch() {
    return !this.isSingleTouch
  }

  get isSingleTouch() {
    return this.event.touches?.length === 1
  }
}
