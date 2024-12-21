import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reload(event) {
    event.preventDefault()
    location.reload(true)
  }
}
