# frozen_string_literal: true

# DevPortal::Patterns::ActionBehaviors
module DevPortal::Patterns::ActionBehaviors
  private

  def pattern
    @pattern ||= Pattern.find(params[:pattern_id])
  end

  def render_updated_grid
    respond_to do |format|
      format.html { redirect_to(edit_dev_portal_pattern_path(pattern)) }
      format.turbo_stream {
        render(
          turbo_stream:
            turbo_stream.replace(
              :pattern_container,
              partial: "dev_portal/patterns/grid",
              locals: {
                view: DevPortal::Patterns::Show.new(pattern),
              }))
      }
    end
  end
end
