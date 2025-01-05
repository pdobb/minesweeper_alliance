import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.#currentUserIsNotASigner()) this.#removeNewCustomGameButton()
  }

  #currentUserIsNotASigner() {
    return document.getElementById("unsignedUserNav")
  }

  #removeNewCustomGameButton() {
    this.element.querySelector("#newCustomGameForm").remove()
  }
}
