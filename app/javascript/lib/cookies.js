// cookies.js

// Cookie management module inspired by Rails' cookie handling.
//
// Usage:
//
// Set a cookie:
//   cookies.set("theme", "dark", { expires: { days: 30 } })
//   cookies.set("time_zone", "America/Chicago", { expires: { hours: 1 } })
//
// Set a permanent cookie (expires in 20 years):
//   cookies.permanent.set("theme", "dark", { httpOnly: true })
//
// Get a cookie:
//   const theme = cookies.get("theme")
//
// Delete a cookie:
//   cookies.delete("theme")

const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = 3_600
const SECONDS_PER_DAY = 86_400
const DEFAULT_COOKIE_DURATION_IN_DAYS = 7
const PERMANENT_COOKIE_DURATION_IN_DAYS = 365

class Cookies {
  constructor() {
    this.permanent = {
      set: this.#setPermanent.bind(this),
    }
  }

  // Set a cookie with the given name and value.
  //
  // @param {string} name - The name of the cookie.
  // @param {string} value - The value of the cookie.
  // @param {Object} options - Options for the cookie.
  set(name, value, options = {}) {
    let expiresIn
    if (options.expiresIn) {
      if (options.expiresIn.seconds) {
        expiresIn = options.expiresIn.seconds
      } else if (options.expiresIn.minutes) {
        expiresIn = options.expiresIn.minutes * SECONDS_PER_MINUTE
      } else if (options.expiresIn.hours) {
        expiresIn = options.expiresIn.hours * SECONDS_PER_HOUR
      } else if (options.expiresIn.days) {
        expiresIn = options.expiresIn.days * SECONDS_PER_DAY
      }
    } else {
      expiresIn = DEFAULT_COOKIE_DURATION_IN_DAYS * SECONDS_PER_DAY
    }

    this.#setCookie(name, value, expiresIn, options)
  }

  // Retrieve the value of a specified cookie.
  //
  // @param {string} name - The name of the cookie to retrieve.
  // @returns {string|null} The cookie value if found, null otherwise.
  get(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2)
      return decodeURIComponent(parts.pop().split(";").shift())
    return null
  }

  // Delete a cookie by setting its expiration to a past date.
  //
  // @param {string} name - The name of the cookie to delete.
  // @param {string} [path='/'] - The path of the cookie to delete, must be same
  //   as when it was set.
  delete(name, path = "/") {
    this.set(name, "", { expires: -1, path })
  }

  #setPermanent(name, value, options = {}) {
    this.#setCookie(
      name,
      value,
      PERMANENT_COOKIE_DURATION_IN_DAYS * SECONDS_PER_DAY,
      options,
    )
  }

  #setCookie(name, value, expiresIn, options) {
    const expires = new Date(Date.now() + expiresIn * 1_000).toUTCString()

    let cookieString = `${name}=${encodeURIComponent(value)}; `
    cookieString += `expires=${expires}; `
    cookieString += `path=${options.path || "/"};`

    if (options.domain) cookieString += `; domain=${options.domain}`
    if (options.httpOnly) cookieString += "; httpOnly"
    if (this.#isSslEnabled()) cookieString += "; Secure"
    if (options.sameSite) cookieString += `; SameSite=${options.sameSite}`
    else cookieString += "; SameSite=Lax"

    document.cookie = cookieString
  }

  #isSslEnabled() {
    window.location.protocol === "https:"
  }
}

export const cookies = new Cookies()
