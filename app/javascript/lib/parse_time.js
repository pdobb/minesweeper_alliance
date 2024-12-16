// ParseTime is called with a given number of `seconds` and returns a timestamp
// represented as `HH:MM:SS`.
export default class ParseTime {
  static secondsPerHour = 3_600
  static secondsPerMinute = 60

  call(seconds) {
    const [hours, remainingSeconds] = this.#parseHours(seconds)

    return [
      hours,
      this.#parseMinutes(remainingSeconds),
      this.#parseSeconds(remainingSeconds),
    ]
  }

  #parseHours(remainingSeconds) {
    const hours = Math.floor(remainingSeconds / ParseTime.secondsPerHour)
    remainingSeconds = remainingSeconds % ParseTime.secondsPerHour
    return [hours, remainingSeconds]
  }

  #parseMinutes(remainingSeconds) {
    return Math.floor(remainingSeconds / ParseTime.secondsPerMinute)
  }

  #parseSeconds(remainingSeconds) {
    return remainingSeconds % ParseTime.secondsPerMinute
  }
}
