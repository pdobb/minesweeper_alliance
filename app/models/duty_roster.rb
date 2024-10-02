# frozen_string_literal: true

# DutyRoster represents the number of Minesweepers (players) currently
# reporting for duty.
#
# @see CurrentGameChannel
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
module DutyRoster
  def self.count
    Rails.cache.fetch(:allies) { 0 }
  end

  def self.increment
    Rails.cache.increment(:allies)
  end

  def self.decrement
    Rails.cache.write(:allies, [count.pred, 0].max)
  end

  def self.clear
    Rails.cache.delete(:allies)
  end
end
