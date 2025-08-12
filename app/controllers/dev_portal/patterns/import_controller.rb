# frozen_string_literal: true

require "csv"

class DevPortal::Patterns::ImportController < DevPortal::BaseController
  include DevPortal::Patterns::ActionBehaviors

  def new
    @form = DevPortal::Patterns::Import::Form.new
  end

  def create
    form =
      DevPortal::Patterns::Import::Form.new(file: form_params[:file])

    if form.import
      url = dev_portal_pattern_path(form.new_pattern)
      respond_to do |format|
        format.html { redirect_to(url) }
        format.turbo_stream do
          render(turbo_stream: turbo_stream.action(:redirect, url))
        end
      end
    else
      @form = form
      render(:new, status: :unprocessable_content)
    end
  end

  private

  def form_params
    return {} unless params.key?(:dev_portal_patterns_import_form)

    params.expect(dev_portal_patterns_import_form: %i[file])
  end
end
