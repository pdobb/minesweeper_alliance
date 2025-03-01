# frozen_string_literal: true

# Application::Pager represents an "infinite scroll" pager.
class Application::Pager
  def self.turbo_target = "pager"

  def initialize(url:)
    @url = url
  end

  # Differentiate self from an Application::EmptyPager instance.
  def empty? = false

  def turbo_target = self.class.turbo_target

  def next_page_url = url

  private

  attr_reader :url
end
