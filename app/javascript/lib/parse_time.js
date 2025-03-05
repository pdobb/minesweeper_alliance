// ParseTime is called with a given number of `seconds` and returns a timestamp
// represented as `HH:MM:SS`.
export default class ParseTime {
  static SECONDS_PER_HOUR = 3_600
  static SECONDS_PER_MINUTE = 60

  call(seconds) {
    const [hours, remainingSeconds] = this.#parseHours(seconds)

    return [
      hours,
      this.#parseMinutes(remainingSeconds),
      this.#parseSeconds(remainingSeconds),
    ]
  }

  #parseHours(remainingSeconds) {
    const hours = Math.floor(remainingSeconds / ParseTime.SECONDS_PER_HOUR)
    remainingSeconds = remainingSeconds % ParseTime.SECONDS_PER_HOUR
    return [hours, remainingSeconds]
  }

  #parseMinutes(remainingSeconds) {
    return Math.floor(remainingSeconds / ParseTime.SECONDS_PER_MINUTE)
  }

  #parseSeconds(remainingSeconds) {
    return remainingSeconds % ParseTime.SECONDS_PER_MINUTE
  }
}
