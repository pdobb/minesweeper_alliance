# frozen_string_literal: true

# Application::EmptyPager represents an empty pager. It is an implementation of
# the Null-Object Pattern, which allows us to use it as a stand-in for
# {Application::Pager} for "infinite scrolling" when there are no pages of
# results left to append.
class Application::EmptyPager
  def turbo_target = Application::Pager.turbo_target

  # Indicate that self is an Application::EmptyPager.
  def empty? = true
end
