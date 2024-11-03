import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    offset: { type: Number, default: 50 },
    delay: { type: Number, default: 200 },
    behavior: { type: String, default: "smooth" },
  }

  jumpToContainer() {
    this.#doScroll(this.element)
  }

  #doScroll(target) {
    const elementPosition =
      target.getBoundingClientRect().top + window.pageYOffset
    const offsetPosition = elementPosition - this.offsetValue

    setTimeout(() => {
      window.scrollTo({
        top: offsetPosition,
        behavior: this.behaviorValue,
      })
    }, this.delayValue)
  }
}
