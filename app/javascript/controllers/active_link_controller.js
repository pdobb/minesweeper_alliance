import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  toggle(event) {
    const $link = event.currentTarget

    if ($link.classList.contains(this.activeClass)) {
      this.#deactivate($link)
      this.dispatch("deactivate")
    } else if (!event.metaKey) {
      // Cmd + Click = "Open Link in New Tab" event.
      // Don't highlight the link as active in that case.
      this.clear()
      this.#activate($link)
    }
  }

  clear() {
    Array.from(this.element.querySelectorAll(`a.${this.activeClass}`)).forEach(
      this.#deactivate.bind(this),
    )
  }

  #activate($link) {
    $link.classList.add(this.activeClass)
  }

  #deactivate($link) {
    $link.classList.remove(this.activeClass)
  }
}
