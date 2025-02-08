# frozen_string_literal: true

module ApplicationHelper
  # A wrapper around Rails's `link_to` helper that adds the given `active_css`
  # (default: "active") to the `link_to`'s CSS class "list" if either:
  #  - The given `url` is the same as the current page's, or
  #  - The current `controller_name` is contained in the given `includes` list.
  # ... and then forwards the rest on to `link_to` as per usual.
  def active_link_to(
        name = nil,
        url = nil,
        active_css: "active",
        includes: [],
        **options,
        &)
    url = name if block_given?

    options[:class] = [
      options[:class],
      { active_css => active_link?(url, includes:) },
    ]

    if block_given?
      link_to(url, **options, &)
    else
      link_to(name, url, **options)
    end
  end

  def external_link_to(name = nil, url = nil, *, **options)
    options.with_defaults!(rel: "noreferrer noopener", target: :_blank)

    options[:class] = [
      "inline-flex items-baseline gap-x-1.5",
      options[:class],
    ]

    link_to(url, *, **options) do
      safe_join([
        tag.span(name),
        inline_svg_tag("heroicons/arrow-top-right-on-square.svg"),
      ])
    end
  end

  # rubocop:disable Metrics/ParameterLists
  def tt(
        anchor,
        content: nil,
        key: anchor.underscore,
        scope: nil,
        on: :hover,
        placement: :top,
        css: {})
    tooltip =
      Application::Tooltip.new(
        anchor,
        content:,
        key:,
        scope:,
        type: on,
        placement:,
        css:,
        context: layout)
    render("application/tooltip", tooltip:)
  end
  # rubocop:enable Metrics/ParameterLists

  private

  def active_link?(url, includes:)
    includes = Array.wrap(includes)
    current_page?(url) || includes.include?(controller.class.name)
  end
end
