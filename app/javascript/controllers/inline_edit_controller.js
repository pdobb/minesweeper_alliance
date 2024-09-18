import { Controller } from "@hotwired/stimulus"

// InlineEditController is responsible for unwinding an intentionally staged
// inline edit form template back to the pre-staged, original content.
//
// Example:
//  The original content (in a partial that we can re-render later):
//    <%= turbo_frame_tag(user) do %>
//      <%= link_to(
//            ..., edit_..._path, class: "edit-link", title: "...",
//            data: { turbo_stream: true }   <-- Allow `turbo_stream`` response.
//          ) %>
//    <% end %>
//
//  The `edit.turbo_stream.erb` template:
//   <%= turbo_stream.update(...) do %>  <-- Replace the original content with:
//     <div
//       data-controller="inline-edit"
//       data-action="keydown.esc@window->inline-edit#cancel"
//     >
//       <div
//         data-inline-edit-target="beforeEdit"
//         class="hidden"
//       >
//         <%= render(...) %>  <-- Re-render the original content here.
//       </div>
//       <div data-inline-edit-target="editing">
//         <%= render(...) %>  <-- Render the inline-edit "form" content here.
//       </div>
//     </div>
//   <% end %>
export default class extends Controller {
  static targets = ["beforeEdit", "editing"]

  cancel() {
    this.beforeEditTarget.replaceWith(...this.beforeEditTarget.childNodes)
    this.editingTarget.remove()
  }
}
