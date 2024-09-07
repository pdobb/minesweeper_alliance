import { Controller } from "@hotwired/stimulus"

// StopwatchController is responsible for displaying time-elapsed in minutes
// and seconds, given an optional start value (in seconds).
export default class extends Controller {
  static values = {
    start: { type: Number, default: 0 },
    interval: { type: Number, default: 1000 },
  }
  static targets = ["elapsedTime"]

  static SECONDS_PER_DAY = 86_400
  static MAX_TIME_DISPLAY_STRING = "23:59:59+"
  static TIME_DIGIT_LENGTH = 2

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
      this.#updateUi(this.constructor.MAX_TIME_DISPLAY_STRING)
    } else {
      this.#updateUi(this.#determineTimestamp())
    }
  }

  #isOverADay() {
    return this.totalSeconds >= this.constructor.SECONDS_PER_DAY
  }

  #updateUi(value) {
    this.elapsedTimeTarget.textContent = value
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
    return value.toString().padStart(this.constructor.TIME_DIGIT_LENGTH, "0")
  }
}

class TimeParser {
  static SECONDS_PER_HOUR = 3_600
  static SECONDS_PER_MINUTE = 60

  parse(totalSeconds) {
    const [hours, remainingSeconds] = this.#parseHours(totalSeconds)

    return [
      hours,
      this.#parseMinutes(remainingSeconds),
      this.#parseSeconds(remainingSeconds),
    ]
  }

  #parseHours(remainingSeconds) {
    const hours = Math.floor(remainingSeconds / TimeParser.SECONDS_PER_HOUR)
    remainingSeconds = remainingSeconds % TimeParser.SECONDS_PER_HOUR
    return [hours, remainingSeconds]
  }

  #parseMinutes(remainingSeconds) {
    return Math.floor(remainingSeconds / TimeParser.SECONDS_PER_MINUTE)
  }

  #parseSeconds(remainingSeconds) {
    return remainingSeconds % TimeParser.SECONDS_PER_MINUTE
  }
}
