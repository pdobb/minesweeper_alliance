import { Controller } from "@hotwired/stimulus"

// GameOverController is responsible for tidying up on-Game-end.
export default class extends Controller {
  static values = { turboStreamChannelName: String }

  connect() {
    this.#disconnectFromWarRoomChannel()
  }

  #disconnectFromWarRoomChannel() {
    const stream = document.querySelector(
      `turbo-cable-stream-source[channel="${this.turboStreamChannelNameValue}"]`,
    )

    if (stream) stream.remove()
  }
}
