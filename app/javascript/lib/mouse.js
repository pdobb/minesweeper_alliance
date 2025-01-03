export default class Mouse {
  static LEFT_BUTTON = 0
  static RIGHT_BUTTON = 2

  constructor(event) {
    this.event = event
  }

  isLeftClick() {
    return this.event.button === this.constructor.LEFT_BUTTON
  }

  isNotLeftClick() {
    return !this.isLeftClick()
  }

  actsAsARightClick() {
    return this.event.ctrlKey && this.isLeftClick() && this.#isMacOS()
  }

  #isMacOS() {
    return navigator.platform.indexOf("Mac") > -1
  }
}
