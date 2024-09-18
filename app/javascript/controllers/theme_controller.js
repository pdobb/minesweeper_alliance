import { Controller } from "@hotwired/stimulus"

class ThemeController extends Controller {
  static STORAGE_KEY = "theme"

  static LIGHT_THEME = "light"
  static LIGHT_THEME_COLOR = "#fff"
  static DARK_THEME = "dark"
  static DARK_THEME_COLOR = "#262626"
  static SYSTEM_THEME = "system"

  static targets = [
    "themeSelectorText",
    "themeSelectorMenu",
    "themeSelectorDropdown",
    "themeSelectorButton",
    "systemThemeButton",
    "lightThemeButton",
    "darkThemeButton",
  ]
  static classes = ["activeThemeButton"]

  static updateThemeColorMetaTag(value) {
    document
      .querySelector('meta[name="theme-color"]')
      .setAttribute("content", value)
  }

  static systemPrefersDarkTheme() {
    return this.windowMatchMedia().matches
  }

  static windowMatchMedia() {
    return window.matchMedia("(prefers-color-scheme: dark)")
  }

  connect() {
    if (this.#shouldBeLightTheme()) {
      this.#setLightTheme()
    } else if (this.#shouldBeDarkTheme()) {
      this.#setDarkTheme()
    } else {
      this.#setSystemTheme()
    }

    ThemeController.windowMatchMedia().addEventListener("change", () => {
      if (this.#shouldBeSystemTheme()) {
        this.#setSystemTheme()
      }
    })
  }

  switchToTheme(event) {
    const name = event.target.value
    const methodName = `switchTo${name}Theme`
    this[methodName]()
  }

  switchToLightTheme() {
    this.#theme = ThemeController.LIGHT_THEME
    this.#setLightTheme()
  }

  switchToDarkTheme() {
    this.#theme = ThemeController.DARK_THEME
    this.#setDarkTheme()
  }

  switchToSystemTheme() {
    this.#theme = ThemeController.SYSTEM_THEME
    this.#setSystemTheme()
  }

  #shouldBeLightTheme() {
    return this.#theme === ThemeController.LIGHT_THEME
  }

  #shouldBeDarkTheme() {
    return this.#theme === ThemeController.DARK_THEME
  }

  #shouldBeSystemTheme() {
    return this.#theme === null
  }

  #setLightTheme() {
    this.#doSetLightTheme()
    this.#activateLightThemeButton()
    this.#activateLightThemeMenuOption()
    this.#activateLightThemeSelectorOption()
  }

  #doSetLightTheme() {
    document.documentElement.classList.remove(ThemeController.DARK_THEME)
    ThemeController.updateThemeColorMetaTag(ThemeController.LIGHT_THEME_COLOR)
  }

  #activateLightThemeButton() {
    this.themeSelectorButtonTargets.forEach((buttonTarget) => {
      buttonTarget.classList.add(...this.activeThemeButtonClasses)
    })
    this.lightThemeButtonTarget.classList.add(...this.activeThemeButtonClasses)
    this.darkThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
    this.systemThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
  }

  #activateLightThemeMenuOption() {
    if (this.hasThemeSelectorMenuTarget) {
      this.#activateMenuSelection(this.lightThemeButtonTarget)
    }
  }

  #activateLightThemeSelectorOption() {
    if (this.hasThemeSelectorDropdownTarget) {
      this.#activateThemeSelectorOption("Light")
    }
  }

  #setDarkTheme() {
    this.#doSetDarkTheme()
    this.#activateDarkThemeButton()
    this.#activateDarkThemeMenuOption()
    this.#activateDarkThemeSelectorOption()
  }

  #doSetDarkTheme() {
    document.documentElement.classList.add(ThemeController.DARK_THEME)
    ThemeController.updateThemeColorMetaTag(ThemeController.DARK_THEME_COLOR)
  }

  #activateDarkThemeButton() {
    this.themeSelectorButtonTargets.forEach((buttonTarget) => {
      buttonTarget.classList.add(...this.activeThemeButtonClasses)
    })
    this.lightThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
    this.darkThemeButtonTarget.classList.add(...this.activeThemeButtonClasses)
    this.systemThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
  }

  #activateDarkThemeMenuOption() {
    if (this.hasThemeSelectorMenuTarget) {
      this.#activateMenuSelection(this.darkThemeButtonTarget)
    }
  }

  #activateDarkThemeSelectorOption() {
    if (this.hasThemeSelectorDropdownTarget) {
      this.#activateThemeSelectorOption("Dark")
    }
  }

  #setSystemTheme() {
    this.#doSetSystemTheme()
    this.#activateSystemThemeButton()
    this.#activateSystemThemeMenuOption()
    this.#activateSystemThemeSelectorOption()
  }

  #doSetSystemTheme() {
    if (ThemeController.systemPrefersDarkTheme()) {
      this.#doSetDarkTheme()
    } else {
      this.#doSetLightTheme()
    }
  }

  #activateSystemThemeButton() {
    this.themeSelectorButtonTargets.forEach((buttonTarget) => {
      buttonTarget.classList.remove(...this.activeThemeButtonClasses)
    })
    this.lightThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
    this.darkThemeButtonTarget.classList.remove(
      ...this.activeThemeButtonClasses,
    )
    this.systemThemeButtonTarget.classList.add(...this.activeThemeButtonClasses)
  }

  #activateSystemThemeMenuOption() {
    if (this.hasThemeSelectorMenuTarget) {
      this.#activateMenuSelection(this.systemThemeButtonTarget)
    }
  }

  #activateSystemThemeSelectorOption() {
    if (this.hasThemeSelectorDropdownTarget) {
      this.#activateThemeSelectorOption("System")
    }
  }

  #activateMenuSelection(target) {
    this.#resetMenuSelection()
    target.setAttribute("aria-selected", "true")
  }

  #resetMenuSelection() {
    this.themeSelectorMenuTarget
      .querySelectorAll("[aria-selected]")
      .forEach((element) => {
        element.setAttribute("aria-selected", "false")
      })
  }

  #activateThemeSelectorOption(name) {
    this.themeSelectorTextTarget.textContent = name
    this.themeSelectorDropdownTarget.value = name
  }

  get #theme() {
    return localStorage.getItem(ThemeController.STORAGE_KEY)
  }

  set #theme(value) {
    if (value == ThemeController.SYSTEM_THEME) {
      localStorage.removeItem(ThemeController.STORAGE_KEY)
    } else {
      localStorage.setItem(ThemeController.STORAGE_KEY, value)
    }
  }
}

export default ThemeController
