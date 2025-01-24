# frozen_string_literal: true

# ActiveSupport::Testing::Assertions overrides.
#
# @see https://github.com/rails/rails/blob/main/activesupport/lib/active_support/testing/assertions.rb
module ActiveSupport::Testing::Assertions # rubocop:disable Metrics/ModuleLength
  # Borrowed from RSpec's `match_array` method, as explained here:
  # https://stackoverflow.com/a/20334260/171183
  #
  # @example
  #   assert_matched_arrays(array1, array2)
  #   value(array2).must_match_array(array1)
  # TODO: this fails for arrays of arrays with the error:
  # ArgumentError: comparison of Array with Array failed.
  def assert_matched_arrays(array1, array2)
    assert_kind_of(Array, (array1 = array1.to_ary.sort))
    assert_kind_of(Array, (array2 = array2.to_ary.sort))
    assert_equal(array1, array2)
  end

  # Run multiple `assert_changes` assertions at once.
  #
  # Notes:
  # - This code is highly borrowed from Rails 7.2's `assert_changes` method.
  # - The block will only be called once regardless of how many change sets
  #   are passed in. So this is also an optimization technique over using
  #   multiple `must_change` calls.
  # - Rubocop is disabled to keep the implementation as close to the original
  #   Rails version as possible.
  #
  # @example
  #   value(-> {
  #     subject.validate
  #   }).must_change_all([
  #     ["subject.attribute1", from: nil, to: 9],
  #     ["subject.attribute2", "My custom message.", from: 9, to: nil]
  #   ])
  #
  # @param change_sets [Array] the `expression`, `message` (Optional), and
  #   options hash that the core `assert_changes` method would normally receive.
  #
  # @see https://github.com/rails/rails/blob/df4386a5d1e591e059116561b41fb2f59eb05f7e/activesupport/lib/active_support/testing/assertions.rb#L195
  #
  # rubocop:disable all
  def assert_changes_to_all(change_sets, &block)
    unless change_sets.is_a?(Array)
      raise(TypeError, "change_sets must be an Array")
    end

    before_values = []

    change_sets.each do |change_set|
      expression = change_set.first

      exp = to_expression(expression, &block)

      before_values << exp.call
    end

    retval = _assert_nothing_raised_or_warn("assert_no_changes", &block)

    change_sets.each.with_index do |change_set, index|
      expression = change_set.first
      message = change_set.second unless change_set.second.is_a?(Hash)

      options = change_set.last
      options = {} unless options.is_a?(Hash)
      from = options.fetch(:from, UNTRACKED)
      to = options.fetch(:to, UNTRACKED)

      before = before_values[index]

      unless from == UNTRACKED
        rich_message = -> {
          code_string = __callable_to_source_string(expression)
          error = "Expected #{code_string.inspect} to change "\
                  "from #{from.inspect}, got #{before.inspect}"
          error = "#{message}.\n#{error}" if message
          error
        }
        assert from === before, rich_message
      end

      exp = to_expression(expression, &block)
      after = exp.call

      rich_message = -> {
        code_string = __callable_to_source_string(expression)
        error = "#{code_string.inspect} didn't change"
        error = "#{error}. It was already #{to.inspect}" if before == to
        error = "#{message}.\n#{error}" if message
        error
      }
      refute_equal before, after, rich_message

      unless to == UNTRACKED
        rich_message = -> {
          code_string = __callable_to_source_string(expression)
          error = "Expected #{code_string.inspect} to change "\
                  "to #{to.inspect}, got #{after.inspect}"
          error = "#{message}.\n#{error}" if message
          error
        }
        assert to === after, rich_message
      end
    end

    retval
  end
  # rubocop:enable all

  # Run multiple `assert_no_changes` assertions at once.
  #
  # Notes:
  # - This code is highly borrowed from Rails 7.2's `assert_no_changes` method.
  # - The block will only be called once regardless of how many change sets
  #   are passed in. So this is also an optimization technique over using
  #   multiple `wont_change` calls.
  # - Rubocop is disabled to keep the implementation as close to the original
  #   Rails version as possible.
  #
  # @example
  #   value(-> {
  #     subject.validate
  #   }).wont_change_all([
  #     ["subject.attribute1"],
  #     ["subject.attribute2", "My custom message."]
  #   ])
  #
  # @param change_sets [Array<Array>] the `expression` and `message` (Optional)
  #   that the core `assert_no_changes` method would normally receive.
  #
  # @see https://github.com/rails/rails/blob/df4386a5d1e591e059116561b41fb2f59eb05f7e/activesupport/lib/active_support/testing/assertions.rb#L252
  #
  # rubocop:disable all
  def assert_no_changes_to_all(change_sets, &block)
    unless change_sets.is_a?(Array)
      raise(TypeError, "change_sets must be an Array")
    end

    before_values = []

    change_sets.each do |change_set|
      expression = change_set.first

      exp = to_expression(expression, &block)

      before_values << exp.call
    end

    retval = _assert_nothing_raised_or_warn("assert_no_changes", &block)

    change_sets.each.with_index do |change_set, index|
      expression = change_set.first
      message = change_set.second

      options = change_set.last
      options = {} unless options.is_a?(Hash)
      from = options.fetch(:from, UNTRACKED)

      before = before_values[index]

      unless from == UNTRACKED
        rich_message = -> {
          code_string = __callable_to_source_string(expression)
          error = "Expected #{code_string.inspect} to have an initial value "\
                  "of #{from.inspect}, got #{before.inspect}"
          error = "#{message}.\n#{error}" if message
          error
        }
        assert from === before, rich_message
      end

      exp = to_expression(expression, &block)

      after = exp.call
      before = before_values[index]

      rich_message = -> {
        code_string = __callable_to_source_string(expression)
        error = "#{code_string.inspect} changed to #{after.inspect}"
        error = "#{message}.\n#{error}" if message
        error
      }
      if before.nil?
        assert_nil after, rich_message
      else
        assert_equal before, after, rich_message
      end
    end

    retval
  end
  # rubocop:enable all

  private

  # Extracted (and cleaned up) from the first line of Rails 8's `assert_changes`
  # and `assert_no_changes` methods.
  # See: https://github.com/rails/rails/blob/df4386a5d1e591e059116561b41fb2f59eb05f7e/activesupport/lib/active_support/testing/assertions.rb#L196
  def to_expression(value, &block)
    if value.respond_to?(:call)
      value
    else
      -> { eval(value.to_s, block.binding) } # rubocop:disable Security/Eval
    end
  end

  # This is an improvement on calling Rails 8's `_callable_to_source_string`
  # method.
  # See: https://github.com/rails/rails/blob/df4386a5d1e591e059116561b41fb2f59eb05f7e/activesupport/lib/active_support/testing/assertions.rb#L301
  def __callable_to_source_string(expression)
    if expression.respond_to?(:call)
      _callable_to_source_string(expression)
    else
      expression
    end
  end
end

# Minitest::Expectations
module Minitest::Expectations
  infect_an_assertion(:assert_matched_arrays, :must_match_array)

  infect_an_assertion(:assert_changes, :must_change, :block)
  infect_an_assertion(:assert_changes_to_all, :must_change_all, :block)

  infect_an_assertion(:assert_no_changes, :wont_change, :block)
  infect_an_assertion(:assert_no_changes_to_all, :wont_change_all, :block)
end
