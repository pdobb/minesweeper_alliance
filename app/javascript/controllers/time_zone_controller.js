import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import { cookies } from "cookies"

// TimeZoneController is responsible for:
// 1. Automatically storing the Current {User}'s local Time Zone, as determined
//    by the browser + JavaScript. Note, however, that we must check if a
//    Current {User} exists first.
// 2. Saving the Current {User}'s self-selected Time Zone.
export default class extends Controller {
  static values = { updateUrl: String }

  connect() {
    if (this.#shouldSetCurrentUserTimeZone()) this.#setCurrentUserTimeZone()
  }

  select(event) {
    this.#submit(event.currentTarget.value)
  }

  #shouldSetCurrentUserTimeZone() {
    return this.#timeZoneCookieDoesNotExist() && this.#userTokenCookieExists()
  }

  #timeZoneCookieDoesNotExist() {
    return cookies.isBlank(window.TIME_ZONE_COOKIE)
  }

  #userTokenCookieExists() {
    return cookies.isPresent(window.USER_COOKIE)
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
