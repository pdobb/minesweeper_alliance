class Mouse {
  static LEFT_BUTTON = 0
  static RIGHT_BUTTON = 2

  constructor(event) {
    this.event = event
  }

  actsAsLeftClick() {
    return this.#isLeftClick && !(this.event.ctrlKey && this.#isMacOS)
  }

  // ctrl + Left Click -> "Right Click" on macOS
  actsAsRightClick() {
    return (
      this.#isRightClick ||
      (this.#isMacOS && this.event.ctrlKey && this.#isLeftClick)
    )
  }

  get #isLeftClick() {
    return this.event.button === Mouse.LEFT_BUTTON
  }

  get #isRightClick() {
    return this.event.button === Mouse.RIGHT_BUTTON
  }

  get #isMacOS() {
    return navigator.platform.indexOf("Mac") > -1
  }
}

export const mouse = (event) => new Mouse(event)
