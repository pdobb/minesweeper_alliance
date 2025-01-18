# frozen_string_literal: true

class UIPortal::Patterns::ToggleFlagsController < UIPortal::BaseController
  include UIPortal::Patterns::ActionBehaviors

  def create
    coordinates = Conversions.Coordinates(coordinates_params.to_h)
    pattern.toggle_flag(coordinates)

    render_updated_grid
  end

  private

  def coordinates_params
    params.expect(toggle_flag: %i[x y])
  end
end
