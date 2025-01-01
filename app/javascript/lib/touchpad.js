export default class Touchpad {
  static LONG_PRESS_TIMEOUT = 250 // ms

  constructor(event) {
    this.event = event
  }

  handleLongPress(onLongPress) {
    if (this.isMultiTouch()) return { cancel: () => {} }

    const timer = window.setTimeout(
      onLongPress,
      this.constructor.LONG_PRESS_TIMEOUT,
    )
    return { cancel: () => clearTimeout(timer) }
  }

  isSingleTouch() {
    return this.event.touches?.length === 1
  }

  isMultiTouch() {
    return !this.isSingleTouch()
  }
}
