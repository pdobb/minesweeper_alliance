import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { cookies } from "cookies"

// Connects to data-controller="timezone"
export default class extends Controller {
  static cookieName = "time_zone"

  static values = { updateUrl: String }

  connect() {
    if (cookies.get(this.constructor.cookieName) == null)
      this.#setCurrentUserTimeZone()
  }

  select(event) {
    this.#submit(event.currentTarget.value)
  }

  #setCurrentUserTimeZone() {
    this.#submit(this.#getlocalTimeZone())
  }

  #getlocalTimeZone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone
  }

  #submit(value) {
    post(this.updateUrlValue, {
      body: { time_zone: value },
    })
  }
}
