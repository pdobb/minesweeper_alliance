# frozen_string_literal: true

# Games::Past::ActiveLinkBehaviors is a mix-in containing common behaviors for
# links that display {Game}s within the "display case".
module Games::Past::ActiveLinkBehaviors
  def link_action
    "active-link#activate"
  end

  def turbo_frame_name
    Games::Past::Show.display_case_turbo_frame_name
  end
end
