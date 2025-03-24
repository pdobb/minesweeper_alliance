# frozen_string_literal: true

# ValidationError facilitates retrieval of Rails' I18n-interpolated error
# messages.
#
# @example
#   subject.validate
#   _(subject.errors[:<attribute>]).wont_include(ValidationError.presence)
#   _(subject.errors[:<attribute>]).must_include(ValidationError.taken)
#
# @see https://guides.rubyonrails.org/i18n.html#error-message-interpolation
module ValidationError
  # Length
  def self.too_long(count) = lookup(:too_long, count:)

  # Numericality
  def self.numericality = lookup(:not_a_number)
  def self.not_an_integer = lookup(:not_an_integer)
  def self.in(count) = lookup(:in, count:)
  def self.less_than(count) = lookup(:less_than, count:)
  def self.less_than_or_equal_to(count) = lookup(:less_than_or_equal_to, count:)
  def self.greater_than(count) = lookup(:greater_than, count:)

  def self.greater_than_or_equal_to(count)
    lookup(:greater_than_or_equal_to, count:)
  end

  # Presence
  def self.taken = lookup(:taken)

  # ActiveRecord Validations
  def self.inclusion = activerecord_lookup(:inclusion)
  def self.absence = activerecord_lookup(:present)
  def self.presence = activerecord_lookup(:blank)
  def self.required_association = activerecord_lookup(:required)
  def self.invariable = activerecord_lookup(:invariable)

  def self.lookup(name, **)
    I18n.t(name, **, scope: %i[errors messages])
  end
  private_class_method :lookup

  def self.activerecord_lookup(name, **)
    I18n.t(name, **, scope: %i[activerecord errors messages])
  end
  private_class_method :activerecord_lookup
end
