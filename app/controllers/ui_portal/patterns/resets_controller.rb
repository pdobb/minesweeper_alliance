# frozen_string_literal: true

class UIPortal::Patterns::ResetsController < UIPortal::BaseController
  include UIPortal::Patterns::ActionBehaviors

  def create
    pattern.reset

    render_updated_grid
  end
end
