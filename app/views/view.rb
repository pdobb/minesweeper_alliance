# frozen_string_literal: true

# View provides easy access to common Rails View-related helpers for use in View
# Models.
module View
  def self.dom_id(...) = helpers.dom_id(...)

  def self.display(value)
    value.present? ? yield(value) : no_value_indicator_tag
  end

  def self.no_value_indicator_tag
    helpers.tag.span("—", class: "text-dim-lg")
  end

  def self.safe_join(...)
    helpers.safe_join(...)
  end

  def self.delimit(...) = helpers.number_with_delimiter(...)

  def self.round(value, precision: 3)
    value.round(precision)
  end

  def self.percentage(value, precision: 2)
    helpers.number_to_percentage(value, precision:)
  end

  def self.pluralize(count, singular, ...)
    helpers.pluralize(count, singular, ...)
  end

  def self.helpers = ActionController::Base.helpers
  private_class_method :helpers
end
