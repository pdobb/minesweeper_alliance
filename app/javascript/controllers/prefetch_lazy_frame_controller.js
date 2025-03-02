import { Controller } from "@hotwired/stimulus"

// PrefetchLazyFrameController loads lazy-loaded turbo_frames before they become
// visible in the viewport.
//
// Use `data-prefetch-lazy-frame-top-margin-value="..."` to adjust the
// sensitivity / top margin at which the prefetch will occur relative to when
// the item will otherwise be scrolled into the viewport.
//
// Reference:
// https://radanskoric.com/articles/load-lazy-loaded-frame-before-it-scrolls-in-view
export default class extends Controller {
  static values = { topMargin: { type: Number, default: 500 } }

  connect() {
    if (this.element.getAttribute("loading") == "lazy") {
      this.observer = new IntersectionObserver(this.intersect, {
        rootMargin: `0px 0px ${this.topMarginValue}px 0px`,
      })
      this.observer.observe(this.element)
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  intersect = (entries) => {
    const lastEntry = entries.slice(-1)[0]

    if (lastEntry?.isIntersecting) {
      this.observer.unobserve(this.element)
      this.element.setAttribute("loading", "eager")
    }
  }
}
