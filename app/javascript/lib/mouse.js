export default class Mouse {
  static LEFT_BUTTON = 0
  static RIGHT_BUTTON = 2

  constructor(event) {
    this.event = event
  }

  actsAsLeftClick() {
    return this.#isLeftClick() && !(this.event.ctrlKey && this.#isMacOS())
  }

  #isLeftClick() {
    return this.event.button === this.constructor.LEFT_BUTTON
  }

  // ctrl + Left Click -> "Right Click" on macOS
  actsAsRightClick() {
    return (
      this.#isRightClick() ||
      (this.event.ctrlKey && this.#isLeftClick() && this.#isMacOS())
    )
  }

  #isRightClick() {
    return this.event.button === this.constructor.RIGHT_BUTTON
  }

  #isMacOS() {
    return navigator.platform.indexOf("Mac") > -1
  }
}
