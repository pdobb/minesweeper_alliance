# frozen_string_literal: true

class DevPortal::Patterns::ExportsController < DevPortal::BaseController
  include DevPortal::Patterns::ActionBehaviors

  def create
    path = Pattern::Export.(pattern:)

    redirect_to(
      dev_portal_pattern_path(pattern),
      notice: "Exported to: #{path.relative_path_from(Rails.root)}",
    )
  end
end
