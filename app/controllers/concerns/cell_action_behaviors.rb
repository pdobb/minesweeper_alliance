# frozen_string_literal: true

# CellActionBehaviors is a Controller mix-in for Controllers that need to
# operate on {Cell}s.
module CellActionBehaviors
  extend ActiveSupport::Concern

  included do
    before_action :require_cell
  end

  private

  def require_cell
    @cell = Cell.find(params[:cell_id])
  end
end
