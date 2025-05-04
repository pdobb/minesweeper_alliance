import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static values = { interactionsUrl: String }

  recordInteraction(event) {
    const element = event.currentTarget
    const interactionName = element.dataset.interactionName

    post(this.interactionsUrlValue, {
      body: {
        interaction: { name: interactionName },
      },
    })
  }

  recordSelectInteraction(event) {
    const element = event.currentTarget
    const interactionName = element.dataset.interactionName
    const selectValue = element.value

    const combinedInteractionName = `${interactionName} (${selectValue})`

    post(this.interactionsUrlValue, {
      body: {
        interaction: { name: combinedInteractionName },
      },
    })
  }
}
