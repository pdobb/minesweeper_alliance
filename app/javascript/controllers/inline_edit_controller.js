import { Controller } from "@hotwired/stimulus"

// InlineEditController is responsible for canceling an inline edit form by
// translating `esc` key presses into a click on the "Cancel" link within the
// form.
//
// Example:
//  # 1. `_<inline_editable>`
//  <%= turbo_frame_tag(<inline_editable-turbo_frame_name>) do %>
//    <%= link_to(
//          <name>,
//          edit_<type>_path,
//          data: { turbo_stream: true }       <-- Allow `turbo_stream` response
//        ) %>
//  <% end %>
//
//  # 2. `edit.html.erb`
//  <%= render("form", form: ...) %>           <-- Render form
//
//  # 3. `_form.html.erb`
//  <%= form_with(model: form.to_model, url: form.update_url) do |f| %>
//    <div
//      data-controller="inline-edit"
//      data-action="keydown.esc@window->inline-edit#cancel"
//    >
//      ...
//      <%= link_to(
//            "Cancel",
//            form.cancel_url,
//            data: {
//              inline_edit_target: "cancel",  <-- Used by `esc` key press
//              turbo_stream: true,            <-- Allow `turbo_stream` response
//            }) %>
//    </div>
//  <% end %>
//
//  # 4. `show.html.erb`
//  <%= render(_<inline_editable>, ...) %>     <-- The original partial (See #1)
//
//  (Not part of the "cancel" function, but... for completeness.)
//  # 5 In-lined into the `update` action (or extracted as
//      `update.turbo_stream.erb`:
//    render(
//      turbo_stream:
//        turbo_stream.update(
//          <inline_editable-turbo_frame_name>,
//          partial: "_<inline_editable>",
//          locals: { ... }))
export default class extends Controller {
  static targets = ["cancel"]

  cancel() {
    this.cancelTarget.click()
  }
}
