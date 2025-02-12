# frozen_string_literal: true

# DevPortal::Patterns::Index is a View Model for displaying the
# UI Portal - Patterns - Index page.
class DevPortal::Patterns::Index
  attr_reader :base_arel

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  def new_pattern_url
    Router.new_dev_portal_pattern_path
  end

  def new_import_pattern_url
    Router.new_dev_portal_patterns_import_path
  end

  def any_listings? = base_arel.any?

  def listings
    Listing.wrap(base_arel)
  end

  # DevPortal::Patterns::Index::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(pattern)
      @pattern = pattern
    end

    def dom_id = View.dom_id(pattern)
    def id = pattern.id
    def name = pattern.name

    def show_pattern_url
      Router.dev_portal_pattern_path(pattern)
    end

    def destroy_pattern_url
      Router.dev_portal_pattern_path(pattern)
    end

    def timestamp
      I18n.l(pattern.created_at, format: :debug)
    end

    private

    attr_reader :pattern
  end
end
