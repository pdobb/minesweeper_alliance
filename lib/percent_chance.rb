# frozen_string_literal: true

# PercentChance provides a {.call} method, for randomly delivering a
# weighted/percent chance of a truthy vs falsy outcome.
module PercentChance
  def self.call(percent)
    rand(1..100) <= percent
  end
end
