# frozen_string_literal: true

# View provides easy access to common Rails View-related helpers for use in View
# Models.
module View
  def self.dom_id(...) = helpers.dom_id(...)

  def self.display(value)
    value.present? ? yield(value) : no_value_indicator
  end

  def self.no_value_indicator = "—"

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

  def self.helpers = ActionController::Base.helpers
  private_class_method :helpers
end
