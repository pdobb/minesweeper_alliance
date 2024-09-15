# frozen_string_literal: true

module ValidationError
  def self.numericality = lookup(:not_a_number)
  def self.not_an_integer = lookup(:not_an_integer)
  def self.too_long(count) = lookup(:too_long, count:)
  def self.less_than(count) = lookup(:less_than, count:)
  def self.greater_than(count) = lookup(:greater_than, count:)

  def self.less_than_or_equal_to(count)
    lookup(:less_than_or_equal_to, count:)
  end

  def self.greater_than_or_equal_to(count)
    lookup(:greater_than_or_equal_to, count:)
  end

  # Uniqueness
  def self.taken = lookup(:taken)

  def self.inclusion = activerecord_lookup(:inclusion)
  def self.absence = activerecord_lookup(:present)
  def self.presence = activerecord_lookup(:blank)
  def self.required_association = activerecord_lookup(:required)
  def self.invariable = activerecord_lookup(:invariable)

  def self.lookup(name, **)
    I18n.t(name, **, scope: %i[errors messages])
  end

  def self.activerecord_lookup(name, **)
    I18n.t(name, **, scope: %i[activerecord errors messages])
  end
end
