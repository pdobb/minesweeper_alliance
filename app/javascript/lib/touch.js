class Touch {
  static DEFAULT_LONG_PRESS_TIMEOUT = 250 // ms

  constructor(event, options = {}) {
    this.event = event
    this.longPressDelay =
      options.longPressDelay || Touch.DEFAULT_LONG_PRESS_TIMEOUT
  }

  onLongPress(callback) {
    if (this.isMultiTouch) return

    return window.setTimeout(callback, this.longPressDelay)
  }

  get isMultiTouch() {
    return !this.isSingleTouch
  }

  get isSingleTouch() {
    return this.event.touches?.length === 1
  }
}

export const touch = (event) => new Touch(event)

export const isMobile = () => {
  const hasTouch = "ontouchstart" in window || navigator.maxTouchPoints > 0
  const hasCoarsePointer = window.matchMedia("(pointer: coarse)").matches
  return hasTouch && hasCoarsePointer
}
