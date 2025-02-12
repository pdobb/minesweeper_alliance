# frozen_string_literal: true

class DevPortal::Patterns::ResetsController < DevPortal::BaseController
  include DevPortal::Patterns::ActionBehaviors

  def create
    pattern.reset

    render_updated_grid
  end
end
