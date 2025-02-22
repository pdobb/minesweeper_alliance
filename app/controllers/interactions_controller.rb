# frozen_string_literal: true

class InteractionsController < ApplicationController
  def create
    if RecordInteraction.record?(current_user:)
      RecordInteraction.(name: create_params[:name])
    end

    head(:no_content)
  end

  private

  def create_params
    params.expect(interaction: :name)
  end
end
