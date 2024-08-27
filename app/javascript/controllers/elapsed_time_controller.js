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

  connect() {
    this.totalSeconds = this.startValue

    if (!this.#isOverOneDay()) {
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

    if (this.#isOverOneDay()) {
      this.#stop()
      this.#updateUi("23:59:59+")
    } else {
      this.#updateUi(this.#determineTimestamp())
    }
  }

  #isOverOneDay() {
    return this.totalSeconds >= this.constructor.SECONDS_PER_DAY
  }

  #updateUi(value) {
    this.elapsedTimeTarget.textContent = value
  }

  #determineTimestamp() {
    return this.#buildTimestamp(...this.#parse())
  }

  #parse() {
    const parser = new TimeParser(this.totalSeconds)
    return parser.parse()
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
    return value.toString().padStart(2, "0")
  }
}

class TimeParser {
  static SECONDS_PER_HOUR = 3_600
  static SECONDS_PER_MINUTE = 60

  constructor(totalSeconds) {
    this.totalSeconds = totalSeconds
  }

  parse() {
    const [hours, remainingSeconds] = this.#parseHours(this.totalSeconds)

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
