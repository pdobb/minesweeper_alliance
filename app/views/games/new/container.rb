# frozen_string_literal: true

# Games::New::Container represents the entire view context surrounding new
# {Game}s, as a partial for reuse.
class Games::New::Container
  def partial_path
    "games/new/container"
  end

  def content
    Games::New::Content.new
  end
end
