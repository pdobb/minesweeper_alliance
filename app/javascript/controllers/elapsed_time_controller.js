import { Controller } from "@hotwired/stimulus"
import ParseTime from "parse_time"

// ElapsedTimeController is responsible for displaying the hours, minutes, and
// seconds elapsed since the start value. The expected start value format is: a
// Unix timestamp (the number of seconds since the Unix Epoch) representing the
// game's start time.
//
// ElapsedTimeController has 2 distinct modalities:
// 1. Formatted Output: Zero-pads hours, minutes, and seconds, as needed, to
//    match the provided format: `HH:MM:SS`, `MM:SS`, or `SS`.
// 2. Compact Output: Display only the minimal information needed--only seconds;
//    only minutes and seconds; or all of: hours, minutes, and seconds--to
//    succinctly convey the elapsed time.
// The default is "Compact Output" mode.
//  -> To switch to "Formatted Output" mode, supply a `format` String.
export default class extends Controller {
  static values = {
    start: Number,
    format: String, // `HH:MM:SS`, `MM:SS`, `SS`, or <none>.
    interval: { type: Number, default: 1_000 }, // ms
    maxSeconds: { type: Number, default: 86_400 },
    maxTimeString: { type: String, default: "23:59:59+" },
  }

  static hoursMinutesSecondsFormat = "HH:MM:SS"
  static minutesSecondsFormat = "MM:SS"
  static secondsFormat = "SS"
  static timeDigitLength = 2

  connect() {
    this.startTimestamp = this.startValue * 1000

    this.#update()
    this.intervalId = setInterval(this.#update.bind(this), this.intervalValue)
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

    if (this.#isMaxedOut(elapsedSeconds)) {
      this.#stop()
      this.#updateUi(this.maxTimeStringValue, elapsedSeconds)
    } else {
      this.#updateUi(this.#format(elapsedSeconds), elapsedSeconds)
    }
  }

  #determineElapsedSeconds() {
    const elapsedMilliseconds = Date.now() - this.startTimestamp
    return Math.floor(elapsedMilliseconds / 1000)
  }

  #isMaxedOut(elapsedSeconds) {
    return elapsedSeconds >= this.maxSecondsValue
  }

  #updateUi(value, elapsedSeconds) {
    this.element.textContent = value
    this.element.setAttribute("datetime", `PT${elapsedSeconds}S`)
  }

  #format(elapsedSeconds) {
    return this.#buildTimestamp(this.#parse(elapsedSeconds))
  }

  // Returns: [[[hours, ][minutes, ]]<seconds>]
  #parse(elapsedSeconds) {
    return new ParseTime().call(elapsedSeconds)
  }

  #buildTimestamp(hoursMinutesSecondsArray) {
    if (this.hasFormatValue) {
      return this.#buildFormattedTimestamp(...hoursMinutesSecondsArray)
    } else {
      return this.#buildCompactTimestamp(...hoursMinutesSecondsArray)
    }
  }

  #buildCompactTimestamp(hours, minutes, seconds) {
    const parts = []

    if (hours > 0) {
      parts.push(this.#pad(hours), this.#pad(minutes))
    } else if (minutes > 0) {
      parts.push(this.#pad(minutes))
    }
    parts.push(this.#pad(seconds))

    return parts.join(":")
  }

  #buildFormattedTimestamp(hours, minutes, seconds) {
    const parts = []

    if (this.formatValue === this.constructor.hoursMinutesSecondsFormat) {
      parts.push(this.#pad(hours), this.#pad(minutes), this.#pad(seconds))
    } else if (this.formatValue === this.constructor.minutesSecondsFormat) {
      parts.push(this.#pad(minutes), this.#pad(seconds))
    } else if (this.formatValue === this.constructor.secondsFormat) {
      parts.push(this.#pad(seconds))
    }

    return parts.join(":")
  }

  #pad(value) {
    return value.toString().padStart(this.constructor.timeDigitLength, "0")
  }
}
