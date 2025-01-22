export const animateOnce = (element, className) => {
  element.classList.add(className)

  element.addEventListener(
    "animationend",
    () => {
      element.classList.remove(className)
    },
    { once: true },
  )
}
