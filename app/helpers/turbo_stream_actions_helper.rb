# frozen_string_literal: true

# TurboStreamActionsHelper houses custom TurboStream action helpers.
#
# References:
# - https://dev.to/drnic/broadcasting-custom-turbo-actions-like-settitle-morph-and-more-3e22
# - https://dev.to/marcoroth/turbo-72-a-guide-to-custom-turbo-stream-actions-4h0e
module TurboStreamActionsHelper
  # Accepts/requires either `target:` or `targets:`, as per the usual
  # turbo-rails convention.
  def replace_css(css: nil, **kwargs)
    unless kwargs.key?(:target) || kwargs.key?(:targets)
      raise(ArgumentError, "must specify either a `target:` or `targets:`")
    end

    tag.turbo_stream(action: :replace_css, css:, **kwargs)
  end
end

Turbo::Streams::TagBuilder.prepend(TurboStreamActionsHelper)
