import { Controller } from "@hotwired/stimulus"

// StopwatchController is responsible for displaying time-elapsed in minutes
// and seconds, given an optional start value (in seconds).
export default class extends Controller {
  static values = {
    start: { type: Number, default: 0 },
    interval: { type: Number, default: 1000 },
  }
  static targets = ["elapsedTime"]

  connect() {
    this.totalSeconds = this.startValue
    this.intervalId = setInterval(this.#update.bind(this), this.intervalValue)
  }

  disconnect() {
    this.#stop()
  }

  #update() {
    this.totalSeconds += 1

    if (this.totalSeconds >= 86_400) {
      this.#stop()
      this.elapsedTimeTarget.textContent = "23:59:59+"
    } else {
      this.elapsedTimeTarget.textContent = this.#determineTimestamp()
    }
  }

  #determineTimestamp() {
    return this.#buildTimestamp(...this.#parse())
  }

  #parse() {
    const parser = new TimeParser(this.totalSeconds)
    return parser.parse()
  }

  #buildTimestamp(hours, minutes, seconds) {
    let parts

    if (hours > 0) {
      parts = [this.#pad(hours), this.#pad(minutes), this.#pad(seconds)]
    } else if (minutes > 0) {
      parts = [this.#pad(minutes), this.#pad(seconds)]
    } else {
      parts = [this.#pad(seconds)]
    }

    return parts.join(":")
  }

  #pad(val) {
    return val.toString().padStart(2, "0")
  }

  #stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
  }
}

class TimeParser {
  constructor(totalSeconds) {
    this.SECONDS_PER_MINUTE = 60
    this.SECONDS_PER_HOUR = 3600

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
    const hours = Math.floor(remainingSeconds / this.SECONDS_PER_HOUR)
    remainingSeconds = remainingSeconds % this.SECONDS_PER_HOUR
    return [hours, remainingSeconds]
  }

  #parseMinutes(remainingSeconds) {
    return Math.floor(remainingSeconds / this.SECONDS_PER_MINUTE)
  }

  #parseSeconds(remainingSeconds) {
    return remainingSeconds % this.SECONDS_PER_MINUTE
  }
}
