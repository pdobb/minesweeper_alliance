import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  set(event) {
    this.clear()
    this.#activate(event.target)
  }

  clear() {
    Array.from(this.element.querySelectorAll("a")).forEach(
      this.#deactivate.bind(this),
    )
  }

  #deactivate($link) {
    $link.classList.remove(...this.activeClasses)
  }

  #activate($link) {
    const id = $link.dataset.activeLinkId

    if (id) {
      this.#activateLinksById(id)
    } else {
      this.#activateLink($link)
    }
  }

  #activateLinksById(id) {
    Array.from(
      this.element.querySelectorAll(`a[data-active-link-id="${id}"]`),
    ).forEach(this.#activateLink.bind(this))
  }

  #activateLink($link) {
    $link.classList.add(...this.activeClasses)
  }
}
