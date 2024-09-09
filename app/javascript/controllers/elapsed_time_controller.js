import { Controller } from "@hotwired/stimulus"

// StopwatchController is responsible for displaying time-elapsed in minutes
// and seconds, given an optional start value (in seconds).
export default class extends Controller {
  static values = {
    start: { type: Number, default: 0 },
    interval: { type: Number, default: 1000 },
  }
  static targets = ["elapsedTime"]

  static secondsPerDay = 86_400
  static maxTimeDisplayString = "23:59:59+"
  static timeDigitLength = 2

  connect() {
    this.totalSeconds = this.startValue

    if (!this.#isOverADay()) {
      this.intervalId = setInterval(this.#update.bind(this), this.intervalValue)
    }
  }

  disconnect() {
    this.#stop()
  }

  #stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
  }

  #update() {
    this.totalSeconds += 1

    if (this.#isOverADay()) {
      this.#stop()
      this.#updateUi(this.constructor.maxTimeDisplayString)
    } else {
      this.#updateUi(this.#determineTimestamp())
    }
  }

  #isOverADay() {
    return this.totalSeconds >= this.constructor.secondsPerDay
  }

  #updateUi(value) {
    this.elapsedTimeTarget.textContent = value
    this.elapsedTimeTarget.setAttribute("datetime", `PT${this.totalSeconds}S`)
    this.elapsedTimeTarget.setAttribute("aria-label", `Elapsed time: ${value}`)
  }

  #determineTimestamp() {
    return this.#buildTimestamp(...this.#parseTotalSeconds())
  }

  // Returns: [[[hours, ][minutes, ]]<seconds>]
  #parseTotalSeconds() {
    return new TimeParser().parse(this.totalSeconds)
  }

  #buildTimestamp(hours, minutes, seconds) {
    const parts = []

    if (hours > 0) {
      parts.push(this.#pad(hours), this.#pad(minutes))
    } else if (minutes > 0) {
      parts.push(this.#pad(minutes))
    }
    parts.push(this.#pad(seconds))

    return parts.join(":")
  }

  #pad(value) {
    return value.toString().padStart(this.constructor.timeDigitLength, "0")
  }
}

class TimeParser {
  static secondsPerHour = 3_600
  static secondsPerMinute = 60

  parse(totalSeconds) {
    const [hours, remainingSeconds] = this.#parseHours(totalSeconds)

    return [
      hours,
      this.#parseMinutes(remainingSeconds),
      this.#parseSeconds(remainingSeconds),
    ]
  }

  #parseHours(remainingSeconds) {
    const hours = Math.floor(remainingSeconds / TimeParser.secondsPerHour)
    remainingSeconds = remainingSeconds % TimeParser.secondsPerHour
    return [hours, remainingSeconds]
  }

  #parseMinutes(remainingSeconds) {
    return Math.floor(remainingSeconds / TimeParser.secondsPerMinute)
  }

  #parseSeconds(remainingSeconds) {
    return remainingSeconds % TimeParser.secondsPerMinute
  }
}
