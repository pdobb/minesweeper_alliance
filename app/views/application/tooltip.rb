# frozen_string_literal: true

# :reek:TooManyInstanceVariables

# Application::Tooltip represents a tooltip, rendered via
# application/_tooltip.html.erb.
#
# @see ApplicationHelper#tt
class Application::Tooltip
  TYPE_OPTIONS = [
    CLICK_TYPE = :click,
    HOVER_TYPE = :hover,
  ].freeze
  private_constant :TYPE_OPTIONS

  PLACEMENT_OPTIONS = %i[
    top
    top-start
    top-end
    right
    right-start
    right-end
    bottom
    bottom-start
    bottom-end
    left
    left-start
    left-end
  ].freeze
  private_constant :PLACEMENT_OPTIONS

  DEFAULT_SCOPE = "tooltips"
  private_constant :DEFAULT_SCOPE

  attr_reader :anchor,
              :content,
              :placement

  # :reek:LongParameterList

  # @attr anchor [String] The text/element(s) for which to display the tooltip.
  # @attr content [String] The text/element(s) to display in the tooltip.
  # @attr scope [#to_sym] The I18n-translatable key/lookup scope.
  # @attr key [#to_sym] An I18n-translatable key/lookup.
  # @attr type [#to_sym] How/when to display the tooltip (see {TYPE_OPTIONS}).
  # @attr placement [#to_sym] Where to display the tooltip (see
  #   {PLACEMENT_OPTIONS}).
  # @attr css [#to_h] CSS class names to pass through to the partial. Expected
  #   keys: `:anchor` or `:content`
  # @attr context [#mobile?] If `context.mobile? == true`, {#type} will be
  #   overridden, for mobile-friendly tooltips.
  def initialize( # rubocop:disable Metrics/ParameterLists
    anchor,
    content:,
    key:,
    scope:,
    type:,
    placement:,
    css:,
    context:
  )
    validate_anchor(anchor)
    validate_content(content ||= translate(key:, scope:))
    validate_type(type = type.to_sym)
    validate_placement(placement = placement.to_sym)

    @anchor = anchor
    @content = content
    @type = type
    @placement = placement
    @css = css.to_h
    @context = context
  end

  def aria_id
    @aria_id ||= "tooltip-#{rand(100_000)}"
  end

  def mobile? = context.mobile?
  def click? = type == CLICK_TYPE
  def hover? = type == HOVER_TYPE

  def anchor_css = css[:anchor]
  def content_css = css[:content]

  private

  attr_reader :type,
              :css,
              :context

  def validate_anchor(anchor)
    raise(TypeError, "anchor can't be blank") if anchor.blank?
  end

  def validate_content(content)
    raise(TypeError, "content can't be blank") if content.blank?
  end

  def validate_type(type)
    return if type.in?(TYPE_OPTIONS)

    raise(TypeError, "type must be one of #{TYPE_OPTIONS.join(", ")}")
  end

  def validate_placement(placement)
    return if placement.in?(PLACEMENT_OPTIONS)

    raise(TypeError, "placement must be one of #{PLACEMENT_OPTIONS.join(", ")}")
  end

  # Precedence order:
  #   "tooltips.<scope>.<key>"
  #   "<scope>.<key>"
  #   "tooltips.<key>"
  #   "<key>"
  def translate(key:, scope:)
    I18n.t(
      :"#{DEFAULT_SCOPE}.#{scope}.#{key}",
      default: [
        :"#{scope}.#{key}",
        :"#{DEFAULT_SCOPE}.#{key}",
        key.to_sym,
      ],
    ).html_safe
  end
end
