# frozen_string_literal: true

# Games::New is represents New {Game}s.
class Games::New
  def container
    Games::New::Container.new
  end
end
