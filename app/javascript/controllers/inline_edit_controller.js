import { Controller } from "@hotwired/stimulus"

// InlineEditController is responsible for canceling an inline edit form by
// translating `esc` key presses into a click on the "Cancel" link within the
// form.
//
// Example:
//  # The original content (in a partial that we can re-render later):
//  <%= turbo_frame_tag(...) do %>
//    <%= link_to(
//          <name>,
//          edit_<type>_path,
//          data: { turbo_stream: true }      <-- Allow `turbo_stream` response.
//        ) %>
//  <% end %>
//
//  # `edit.turbo_stream.erb` template:
//  <%= turbo_stream.update(...) do %>
//    <div
//      data-controller="inline-edit"
//      data-action="keydown.esc@window->inline-edit#cancel"
//    >
//      <%= render(".../form", form: ...) %>  <-- Render form content here.
//    </div>
//  <% end %>
//
//  # `.../_form.html.erb` template:
//  <%= form_with(
//        model: form.to_model,
//        url: form.post_url,
//        id: form.dom_id) do |f| %>          <-- Must match turbo frame name.
//    ...
//    <%= link_to(
//          "Cancel",
//          form.cancel_url,
//          data: {
//            inline_edit_target: "cancel",   <-- Used by `esc` key press.
//            turbo_stream: true,             <-- Allow `turbo_stream` response.
//          }) %>
//  <% end %>
export default class extends Controller {
  static targets = ["cancel"]

  cancel() {
    this.cancelTarget.click()
  }
}
