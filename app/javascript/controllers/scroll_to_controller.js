import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    offset: { type: Number, default: 50 },
    delay: { type: Number, default: 200 },
    behavior: { type: String, default: "smooth" },
    threshold: { type: Number, default: -200 },
  }

  jumpToContainer() {
    this.#doScroll(this.element)
  }

  #doScroll($target) {
    const scrollTarget = new ScrollTarget($target)
    if (scrollTarget.isOnScreen({ threshold: this.thresholdValue })) return

    const offsetPosition = scrollTarget.scrollPosition - this.offsetValue

    setTimeout(() => {
      window.scrollTo({
        top: offsetPosition,
        behavior: this.behaviorValue,
      })
    }, this.delayValue)
  }
}

class ScrollTarget {
  constructor(element) {
    this.element = element
  }

  get bounds() {
    return this.element.getBoundingClientRect()
  }

  get scrollPosition() {
    return this.bounds.top + window.pageYOffset
  }

  isOnScreen({ threshold = 0 } = {}) {
    const viewportHeight =
      window.innerHeight || document.documentElement.clientHeight
    return this.bounds.top < viewportHeight + threshold
  }
}
