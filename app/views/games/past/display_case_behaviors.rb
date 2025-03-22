# frozen_string_literal: true

# Games::Past::DisplayCaseBehaviors is a mix-in containing common behaviors for
# displaying {Game}s within a "display case".
module Games::Past::DisplayCaseBehaviors
  def stimulus_action
    "active-link:deactivate@window->display-case#hide"
  end

  def container_css
    "px-(--page-px) py-12 -mx-3"
  end

  def turbo_frame_name
    Games::Past::Container.display_case_turbo_frame_name
  end
end
