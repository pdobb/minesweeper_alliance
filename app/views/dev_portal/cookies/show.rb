# frozen_string_literal: true

# DevPortal::Cookies::Show represents ...
class DevPortal::Cookies::Show
  TRUNCATE_SECRET_KEY_BASE_AT = 10

  def initialize(context:)
    @cookies = context.__send__(:cookies)
  end

  def secret_key_base_from_config
    Rails.application.secret_key_base.truncate(
      TRUNCATE_SECRET_KEY_BASE_AT,
    )
  end

  def secret_key_base_from_credentials
    Rails.application.credentials.secret_key_base.truncate(
      TRUNCATE_SECRET_KEY_BASE_AT,
    )
  end

  def entries
    Entry.wrap_hash(cookies.instance_variable_get(:@cookies).sort, cookies:)
  end

  private

  attr_reader :cookies

  # DevPortal::Cookies::Show::Entry
  class Entry
    include WrapMethodBehaviors

    attr_reader :key,
                :value

    def initialize(key, value, cookies:)
      @key = key
      @value = value
      @cookies = cookies
    end

    def signed_value? = signed_value.present?
    def signed_value = cookies.signed[key]

    private

    attr_reader :cookies
  end
end
