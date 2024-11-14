# frozen_string_literal: true

# Audit is a custom ActiveRecord::Serialization type for storing text with a
# hash-key lookup and rendering it back as a String with a given separator.
#
# @example
#   audit = Audit.new(a: 1, b: 2)
#   # => <Audit {"a"=>1, "b"=>2}>
#
#   audit.to_s  # => "1 / 2"
#   audit[:a]   # => 1
#   audit["b"]  # => 2
#   audit.to_h  # => { a: 1, b: 2 }
#   audit.to_a  # => [1, 2 ]
class Audit
  include ObjectInspector::InspectorsHelper

  def self.load(string)
    hash = string.present? ? ActiveSupport::JSON.decode(string) : {}
    new(hash)
  end

  def self.dump(obj)
    unless obj.is_a?(self)
      raise ::ActiveRecord::SerializationTypeMismatch,
            "#{self} expected; received #{obj.class} :: #{obj.inspect}"
    end

    ActiveSupport::JSON.encode(obj.to_h)
  end

  def initialize(audit_hash = {})
    @audit_hash = audit_hash.to_h.with_indifferent_access
  end

  def ==(other)
    to_h == other.to_h
  end
  alias_method :eql?, :==

  def to_s(separator: " / ")
    to_a.join(separator)
  end

  def [](identifier)
    to_h[identifier]
  end

  def to_h = @audit_hash
  def to_a = to_h.values
  def key?(...) = to_h.key?(...)

  private

  def inspect_info
    to_h
  end
end
