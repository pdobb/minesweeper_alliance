# frozen_string_literal: true

# View provides easy access to common Rails View-related helpers for use in View
# Models.
module View
  def self.dom_id(...) = helpers.dom_id(...)

  def self.display(value)
    value.present? ? yield(value) : no_value_indicator_tag
  end

  def self.no_value_indicator_tag
    helpers.tag.span("—", class: "text-dim-lg")
  end

  # Provides a Turbo target for {User#display_name} updates.
  def self.updateable_display_name(user:)
    helpers.tag.span(user.display_name, class: dom_id(user, :display_name))
  end

  # Provides a Turbo target for {User#username} updates.
  def self.updateable_username(user:)
    helpers.tag.span(user.username, class: dom_id(user, :username))
  end

  def self.safe_join(...)
    helpers.safe_join(...)
  end

  def self.delimit(...) = helpers.number_with_delimiter(...)

  def self.round(value, precision: 3)
    value.round(precision)
  end

  def self.percentage(value, precision: 2)
    helpers.number_to_percentage(value, precision:)
  end

  # :reek:ControlParameter

  # Simplifies Rails 8's `pluralize` helper.
  # @see https://github.com/rails/rails/blob/main/actionview/lib/action_view/helpers/text_helper.rb#L290
  def self.pluralize(word, count:)
    word = word.pluralize unless count == 1
    "#{count || 0} #{word}"
  end

  # Simplifies and combines Rails 8's `pluralize` and `delimit` helpers.
  def self.delimited_pluralize(word, count:)
    word = word.pluralize unless count == 1
    count = count ? delimit(count) : 0

    "#{count} #{word}"
  end

  def self.helpers = ActionController::Base.helpers
  private_class_method :helpers
end
