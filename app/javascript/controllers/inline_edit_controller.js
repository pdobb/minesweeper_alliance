import { Controller } from "@hotwired/stimulus"

// InlineEditController is responsible for canceling an inline edit form by
// translating `esc` key presses into a click on the "Cancel" link within the
// form.
//
// Example:
//  # NOTE: You may or may not need to break out the inline-edit-form into a
//  # container/content relationship as in 1a and 1b below:
//
//  # 1a. The main container frame (renders our reusable partial):
//  <%= turbo_frame_tag(...) do %>
//    <%= render("_...") %>
//  <% end %>
//
//  # 1b. The reusable partial (`"_..."`) from above:
//  <%= link_to(
//        <name>,
//        edit_<type>_path,
//        data: { turbo_stream: true }      <-- Allow `turbo_stream` response.
//      ) %>
//
//  # 2. `edit.turbo_stream.erb` template:
//  <%= turbo_stream.update(...) do %>
//    <div
//      data-controller="inline-edit"
//      data-action="keydown.esc@window->inline-edit#cancel"
//    >
//      <%= render(".../form", form: ...) %>  <-- Render form content here.
//    </div>
//  <% end %>
//
//  # 3. `.../_form.html.erb` template:
//  <%= form_with(model: form.to_model, url: form.post_url) do |f| %>
//    ...
//    <%= link_to(
//          "Cancel",
//          form.cancel_url,
//          data: {
//            inline_edit_target: "cancel",   <-- Used by `esc` key press.
//            turbo_stream: true,             <-- Allow `turbo_stream` response.
//          }) %>
//  <% end %>
//
//  # 4. The above cancel link has to render a view that includes the original
//  #    frame tag and content:
//  <%= turbo_frame_tag(...) do %>
//    <%= render("_...") %>                   <-- The reusable partial.
//  <% end %>
export default class extends Controller {
  static targets = ["cancel"]

  cancel() {
    this.cancelTarget.click()
  }
}
