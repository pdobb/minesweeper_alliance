# frozen_string_literal: true

ActionView::Base.field_error_proc =
  proc do |html_tag, _instance|
    tag =
      if html_tag.include?('class="')
        html_tag.sub('class="', 'class="form-error ')
      else
        tag_name = html_tag.match(/<(label|input|select|textarea)/)[1]
        html_tag.sub("<#{tag_name}", "<#{tag_name} class=\"form-error\"")
      end

    tag.to_s.html_safe # rubocop:disable Rails/OutputSafety
  end
