# frozen_string_literal: true

# Games::JustEnded::FooterPartialOptions handles building out the proper footer
# partial's rendering options based on whether or not the passed-in
# {User} participated in, or was just a spectator of, the passed-in{Game}.
class Games::JustEnded::FooterPartialOptions
  include CallMethodBehaviors

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def call
    { partial:, locals: }
  end

  private

  attr_reader :game,
              :user

  def partial
    "games/just_ended/#{type}/footer"
  end

  def locals
    { footer: footer(type.camelize) }
  end

  def type
    @type ||= active_participant? ? "active_participants" : "observers"
  end

  def active_participant?
    @active_participant ||= user.active_participant_in?(game:)
  end

  def footer(sub_type)
    "Games::JustEnded::#{sub_type}::Footer".constantize.new(game:, user:)
  end
end
