# frozen_string_literal: true

require "csv"

class UIPortal::Patterns::ImportsController < UIPortal::BaseController
  include UIPortal::Patterns::ActionBehaviors

  def new
    @import_form = ImportForm.new
  end

  def create
    import_form = ImportForm.new(file: import_form_params[:file])

    if import_form.import
      redirect_to(ui_portal_pattern_path(import_form.new_pattern))
    else
      @import_form = import_form
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def import_form_params
    unless params.key?(:ui_portal_patterns_imports_controller_import_form)
      return {}
    end

    params.require(:ui_portal_patterns_imports_controller_import_form).permit(
      :file)
  end

  # UIPortal::Patterns::ImportsController::ImportForm is a form model.
  class ImportForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :new_pattern

    attribute :file

    validates :file,
              presence: true

    def import
      return false unless valid?

      @new_pattern = Pattern::Import.(path: file)
      return true if new_pattern.valid?

      errors.merge!(new_pattern.errors)
      false
    end

    def new_pattern_name = new_pattern.name
  end
end
