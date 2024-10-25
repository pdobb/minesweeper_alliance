# frozen_string_literal: true

module ApplicationHelper
  # #active_link_to is a wrapper around Rails's `link_to` helper that adds
  # the given `active_css_class` (default: "active") to the `link_to`'s CSS
  # class "list" if either:
  #  - The given `url` is the same as the current page's, or
  #  - The current `controller_name` is contained in the given `includes` list.
  # Then it just forwards the rest on to `link_to` as per usual.
  def active_link_to(
        name = nil,
        url = nil,
        active_css_class: "active",
        includes: [],
        **options,
        &)
    url = name if block_given?

    options[:class] = [
      options[:class],
      { active_css_class => active_link?(url, includes:) },
    ]

    if block_given?
      link_to(url, **options, &)
    else
      link_to(name, url, **options)
    end
  end

  def external_link_to(name = nil, url = nil, *, **options)
    options.with_defaults!({ rel: "noreferrer noopener", target: :_blank })
    link_to(name, url, *, **options)
  end

  private

  def active_link?(url, includes:)
    includes = Array.wrap(includes)
    current_page?(url) || includes.include?(controller.class.name)
  end
end
