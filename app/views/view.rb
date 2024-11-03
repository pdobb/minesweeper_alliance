# frozen_string_literal: true

# View provides easy access to common Rails View-related helpers for use in View
# Models.
module View
  def self.delimit(value)
    helpers.number_with_delimiter(value)
  end

  def self.round(value, precision: 3)
    value.round(precision)
  end

  def self.percentage(value, precision: 2)
    helpers.number_to_percentage(value, precision:)
  end

  def self.display(value)
    value.present? ? yield(value) : no_value_indicator
  end

  def self.no_value_indicator = "—"

  def self.helpers = ActionController::Base.helpers
  private_class_method :helpers
end