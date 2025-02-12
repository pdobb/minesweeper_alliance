# frozen_string_literal: true

# UserUpdateTransaction records update events on a {User}'s "profile" (record).
# Currently, this just includes updates to {User#username}, but the
# {#change_set} can be dynamically expanded.
#
# @attr user_id [Integer] References the {User} involved in this Transaction.
# @attr change_set [Hash] A Hash of old/new values for changes to the associated
#   {User} record.
# @attr created_at [DateTime] When this Transaction occurred.
class UserUpdateTransaction < ApplicationRecord
  self.implicit_order_column = "created_at"

  include ConsoleBehaviors

  belongs_to :user

  validates :change_set, presence: true

  scope :has_key_username, -> { has_key("username") }
  scope :has_key, ->(key) { where("change_set ? :key", key:) }

  def self.create_for(user:, change_set:)
    user.user_update_transactions.create!(change_set:)
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify

    def inspect_info
      [
        [user.inspect, change_set.inspect].join(" -> "),
        I18n.l(created_at, format: :debug),
      ].join(" @ ")
    end
  end
end
