# frozen_string_literal: true

# Games::New is represents New {Game}s.
class Games::New
  def template_path
    "games/new"
  end

  def content
    Games::New::Content.new
  end
end
