import { Controller } from "@hotwired/stimulus"
import ParseTime from "parse_time"

// ElapsedTimeController is responsible for displaying time-elapsed in minutes
// and seconds, given an optional start value (in seconds).
export default class extends Controller {
  static values = {
    start: { type: Number, default: 0 },
    interval: { type: Number, default: 1000 },
  }

  static secondsPerDay = 86_400
  static maxTimeDisplayString = "23:59:59+"
  static timeDigitLength = 2

  connect() {
    this.startTimestamp = Date.now() - this.startValue * 1000

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
    const elapsedSeconds = this.#determineElapsedSeconds()

    if (this.#isOverADay(elapsedSeconds)) {
      this.#stop()
      this.#updateUi(this.constructor.maxTimeDisplayString, elapsedSeconds)
    } else {
      this.#updateUi(this.#formatTime(elapsedSeconds), elapsedSeconds)
    }
  }

  #determineElapsedSeconds() {
    const elapsedMilliseconds = Date.now() - this.startTimestamp
    return Math.floor(elapsedMilliseconds / 1000)
  }

  #isOverADay(elapsedSeconds) {
    return elapsedSeconds >= this.constructor.secondsPerDay
  }

  #updateUi(value, elapsedSeconds) {
    this.element.textContent = value
    this.element.setAttribute("datetime", `PT${elapsedSeconds}S`)
  }

  #formatTime(elapsedSeconds) {
    return this.#buildTimestamp(...this.#parseTime(elapsedSeconds))
  }

  // Returns: [[[hours, ][minutes, ]]<seconds>]
  #parseTime(elapsedSeconds) {
    return new ParseTime().call(elapsedSeconds)
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
