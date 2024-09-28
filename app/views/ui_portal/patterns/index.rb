# frozen_string_literal: true

# UIPortal::Patterns::Index is a View Model for displaying the
# UI Portal - Patterns - Index page.
class UIPortal::Patterns::Index
  attr_reader :base_arel

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  def new_pattern_url(router = RailsRouter.instance)
    router.new_ui_portal_pattern_path
  end

  def new_import_pattern_url(router = RailsRouter.instance)
    router.new_ui_portal_patterns_import_path
  end

  def any_listings? = base_arel.any?

  def listings
    Listing.wrap(base_arel)
  end

  # UIPortal::Patterns::Index::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(pattern)
      @pattern = pattern
    end

    def to_model = @pattern

    def dom_id(context)
      context.dom_id(to_model)
    end

    def id = to_model.id

    def name = to_model.name

    def show_pattern_url(router = RailsRouter.instance)
      router.ui_portal_pattern_path(to_model)
    end

    def destroy_pattern_url(router = RailsRouter.instance)
      router.ui_portal_pattern_path(to_model)
    end

    def timestamp
      I18n.l(to_model.created_at, format: :debug)
    end
  end
end
