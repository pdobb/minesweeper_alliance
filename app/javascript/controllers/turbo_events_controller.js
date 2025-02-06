import { Controller } from "@hotwired/stimulus"

// TurboEventsController presents an opportunity for context-driven DOM
// elements to opt-in to Turbo event monitoring/responses/prevention.
export default class extends Controller {
  preventRefresh(event) {
    if (event.detail.newStream.action == "refresh") {
      event.preventDefault()
    }
  }
}
