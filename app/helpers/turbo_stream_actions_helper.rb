# frozen_string_literal: true

# TurboStreamActionsHelper defines our custom turbo-rails actions.
#
# Notes:
# - `@view_context` comes from Turbo::Streams::TagBuilder in the turbo-rails
#   gem. See: https://github.com/hotwired/turbo-rails/blob/0ea92f344395234dd7fc39b0ef9ab02388e33235/app/models/turbo/streams/tag_builder.rb#L47
module TurboStreamActionsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def sourced_replace_for(view_model, method: :morph)
    tag.turbo_stream(
      tag.template(@view_context.render(partial: view_model, formats: :html)),
      action: :replace,
      target: view_model.dom_id,
      method:,
      data: { source: @view_context.cookies[User::Current::COOKIE] })
  end
  # rubocop:enable Rails/HelperInstanceVariable
end

Turbo::Streams::TagBuilder.prepend(TurboStreamActionsHelper)
