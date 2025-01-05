import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element
      .querySelectorAll('input[type="text"], input[type="email"]')
      .forEach((element) => {
        element.classList.add("form-input")
      })

    this.element.querySelectorAll("textarea").forEach((element) => {
      element.classList.add("form-textarea")
    })
  }
}
