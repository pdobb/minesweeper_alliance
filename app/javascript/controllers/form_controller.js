import { Controller } from "@hotwired/stimulus"

// FormController facilitates setting up an alternate form-submission action for
// `button_to` elements/forms using stimulus events.
//
// @example
//   <%=
//     if App.debug?
//       debug_mode_data_attributes = {
//         controller: "form",
//         form_alternate_url_value: ...,
//         action: "contextmenu->form#alternateSubmit:prevent",
//       }
//     end
//
//     button_to("...", ..., data: { ..., **debug_mode_data_attributes.to_h })
//   %>
export default class extends Controller {
  static values = { alternateUrl: String }

  alternateSubmit() {
    const form = this.element.closest("form")
    form.action = this.alternateUrlValue
    this.element.click()
  }
}
