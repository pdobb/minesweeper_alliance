// cookies.js

// Cookie management module inspired by Rails' cookie handling.
//
// Usage:
//
// Set a cookie:
//   cookies.set("theme", "dark", { expires: 30, secure: true })
//
// Set a permanent cookie (expires in 20 years):
//   cookies.permanent.set("theme", "dark", { secure: true })
//
// Get a cookie:
//   const theme = cookies.get("theme")
//
// Delete a cookie:
//   cookies.delete("theme")

const PERMANENT_COOKIE_DAYS = 365 * 20

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
    let days = options.expires || 7
    this.#setCookie(name, value, days, options)
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
    this.#setCookie(name, value, PERMANENT_COOKIE_DAYS, options)
  }

  #setCookie(name, value, days, options) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString()
    let cookieString = `${name}=${encodeURIComponent(value)}; expires=${expires}; path=${options.path || "/"};`

    if (options.domain) cookieString += `; domain=${options.domain}`
    if (options.secure) cookieString += "; secure"
    if (options.httpOnly) cookieString += "; httpOnly"
    if (options.sameSite) cookieString += `; SameSite=${options.sameSite}`
    else cookieString += "; SameSite=Lax"

    document.cookie = cookieString
  }
}

export const cookies = new Cookies()
