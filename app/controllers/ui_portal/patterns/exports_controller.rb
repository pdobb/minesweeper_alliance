# frozen_string_literal: true

class UIPortal::Patterns::ExportsController < UIPortal::BaseController
  include UIPortal::Patterns::ActionBehaviors

  def create
    path = Pattern::Export.(pattern:)

    redirect_to(
      ui_portal_pattern_path(pattern),
      notice: "Exported to: #{path.relative_path_from(Rails.root)}")
  end
end
