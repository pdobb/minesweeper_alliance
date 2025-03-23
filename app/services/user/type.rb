# frozen_string_literal: true

# User::Type fulfills "Type"/Classification-related business logic for {User}s.
module User::Type
  SPAMMER_GAMES_COUNT_THRESHOLD = 10
  private_constant :SPAMMER_GAMES_COUNT_THRESHOLD

  def self.dev?(user) = user.token.in?(dev_tokens)
  def self.non_dev?(user) = !dev?(user)

  def self.dev_tokens = @dev_tokens ||= User.is_dev.ids
  private_class_method :dev_tokens

  def self.spammer?(user, threshold: SPAMMER_GAMES_COUNT_THRESHOLD)
    return false if dev?(user)

    user.actively_participated_in_games.is_spam.count > threshold
  end
end
