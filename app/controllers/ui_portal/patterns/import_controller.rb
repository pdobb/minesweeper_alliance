# frozen_string_literal: true

require "csv"

class UIPortal::Patterns::ImportController < UIPortal::BaseController
  include UIPortal::Patterns::ActionBehaviors

  def new
    @form = UIPortal::Patterns::Import::Form.new
  end

  def create
    form =
      UIPortal::Patterns::Import::Form.new(file: form_params[:file])

    if form.import
      url = ui_portal_pattern_path(form.new_pattern)
      respond_to do |format|
        format.html { redirect_to(url) }
        format.turbo_stream do
          render(turbo_stream: turbo_stream.action(:redirect, url))
        end
      end
    else
      @form = form
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def form_params
    return {} unless params.key?(:ui_portal_patterns_import_form)

    params.expect(ui_portal_patterns_import_form: %i[file])
  end
end
