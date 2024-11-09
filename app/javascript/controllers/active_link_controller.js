import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["active"]

  activate(event) {
    // Activate unless Cmd + Click ("Open Link in New Tab") detected.
    if (event.metaKey) return

    this.clear()

    const $link = event.currentTarget
    this.#activateAllByHref($link.href)
  }

  clear() {
    Array.from(this.element.querySelectorAll(`a.${this.activeClass}`)).forEach(
      this.#deactivate.bind(this),
    )
  }

  #isActive($link) {
    return $link.classList.contains(this.activeClass)
  }

  #activateAllByHref(href) {
    this.#allLinks().forEach(($link) => {
      if ($link.href === href) this.#activate($link)
    })
  }

  #allLinks() {
    return this.element.querySelectorAll("a")
  }

  #activate($link) {
    $link.classList.add(this.activeClass)
  }

  #deactivate($link) {
    $link.classList.remove(this.activeClass)
  }
}
