# frozen_string_literal: true

# Games::Past::DisplayCaseBehaviors is a mix-in containing common behaviors for
# displaying {Game}s within a "display case".
module Games::Past::DisplayCaseBehaviors
  def stimulus_action
    "active-link:deactivate@window->display-case#hide"
  end

  def container_css
    "px-6 py-12 -mx-3"
  end

  def turbo_frame_name
    Games::Past::Show.turbo_frame_name
  end
end
