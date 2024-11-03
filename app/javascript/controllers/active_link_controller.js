import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  toggle(event) {
    const $link = event.currentTarget

    if ($link.classList.contains(this.activeClass)) {
      this.#deactivate($link)
      this.dispatch("deactivate")
    } else {
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
