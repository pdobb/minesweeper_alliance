# frozen_string_literal: true

# User::Prune handles removing all prunable {User}s from the database.
# Prunable {Users}:
# - are at least a day old, and
# - have no active {ParticipantTransaction}s.
#
# @example
#   User::Prune.call
#
# @example Dry Run
#   User::Prune.dry_run
#
# @see config/recurring.yml
module User::Prune
  def self.count = base_arel.count
  def self.user_agents_tally = base_arel.pluck(:user_agent).tally

  def self.call
    decorate do
      base_arel.each do |user|
        user.destroy
        Say.success("Pruned: #{describe(user)}")
      end
    end
  end

  def self.dry_run
    decorate do
      base_arel.each { |user| Say.info("Will prune: #{describe(user)}") }
    end
  end

  class << self
    private

    def base_arel = User.for_prune.by_least_recent

    def decorate
      Say.silent("Pruning #{count} Users") do
        Say.(user_agents_tally)

        results_count = yield.size

        Say.info("No prunable Users found.") if results_count.zero?
      end

      self
    end

    def describe(user) = user.identify(:id, :created_at, :user_agent)
  end
end
