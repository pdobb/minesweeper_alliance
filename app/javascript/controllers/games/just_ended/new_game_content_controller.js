import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.#currentUserIsNotASigner()) this.#removeNewCustomGameButton()
  }

  #currentUserIsNotASigner() {
    return !document.querySelector('#currentUserNav [data-signer="true"]')
  }

  #removeNewCustomGameButton() {
    this.element.querySelector("#newCustomGameButton").remove()
  }
}
