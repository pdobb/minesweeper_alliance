# frozen_string_literal: true

# UIPortal::Patterns::ActionBehaviors
module UIPortal::Patterns::ActionBehaviors
  private

  def pattern
    @pattern ||= Pattern.find(params[:pattern_id])
  end

  def render_updated_grid
    respond_to do |format|
      format.html { redirect_to(edit_ui_portal_pattern_path(pattern)) }
      format.turbo_stream {
        render(
          turbo_stream:
            turbo_stream.replace(
              :pattern_container,
              partial: "ui_portal/patterns/grid",
              locals: {
                view: UIPortal::Patterns::Show.new(pattern),
              }))
      }
    end
  end
end
