import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = { interactionsUrl: String }

  reload(event) {
    event.preventDefault()
    location.reload(true)
  }

  recordInteraction(event) {
    post(this.interactionsUrlValue, {
      body: {
        interaction: { name: event.currentTarget.dataset.interactionName },
      },
    })
  }
}
