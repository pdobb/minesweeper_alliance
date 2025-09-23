# frozen_string_literal: true

# :reek:InstanceVariableAssumption

class DevPortal::PatternsController < DevPortal::BaseController
  before_action :require_pattern, only: %i[show edit update destroy]

  def index
    @index = DevPortal::Patterns::Index.new(base_arel: Pattern.by_most_recent)
  end

  def show
    @show = DevPortal::Patterns::Show.new(pattern)
  end

  def new
    @new = DevPortal::Patterns::New.new(context: layout)
  end

  def create # rubocop:disable Metrics/AbcSize
    settings = Pattern::Settings.new(new_pattern_params[:settings])
    pattern = Pattern.new(name: new_pattern_params[:name], settings:)

    if pattern.save
      store_pattern_settings(settings)

      respond_to do |format|
        format.html { redirect_to(root_path) }
        format.turbo_stream do
          render(
            turbo_stream:
              turbo_stream.action(:redirect, dev_portal_pattern_path(pattern)),
          )
        end
      end
    else
      @new = DevPortal::Patterns::New.new(pattern, context: layout)
      render(:new, status: :unprocessable_content)
    end
  end

  def edit; end

  def update
    pattern.attributes = edit_pattern_params
    if pattern.save
      redirect_to({ action: :show, id: pattern })
    else
      render(:edit)
    end
  end

  # :reek:DuplicateMethodCall

  def destroy # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    pattern.destroy

    respond_to do |format|
      format.html { redirect_to_index_after_destroy(pattern) }
      format.turbo_stream {
        # Not sure of a good way around this hack... But we want to use a Turbo
        # Stream for destruction from the Index page, while using redirect for
        # destruction from the Show page.
        if request.referer.include?(dev_portal_pattern_path(pattern))
          redirect_to_index_after_destroy(pattern)
        else # Index page
          render(turbo_stream: turbo_stream.remove(pattern))
        end
      }
    end
  end

  private

  attr_accessor :pattern

  def require_pattern
    return if (self.pattern = Pattern.for_id(params[:id]).take)

    redirect_to(
      { action: :index }, alert: t("flash.not_found", type: "Pattern")
    )
  end

  def new_pattern_params
    params.expect(
      pattern: [
        :name,
        { settings: %i[width height] },
      ],
    )
  end

  def edit_pattern_params
    params.expect(pattern: %i[name])
  end

  def store_pattern_settings(settings)
    layout.store_http_cookie(
      DevPortal::Patterns::New::SettingsForm::COOKIE,
      value: settings.to_json,
    )
  end

  def redirect_to_index_after_destroy(pattern)
    redirect_to(
      { action: :index },
      notice:
        t("flash.successful_destroy_with_name",
          type: "Pattern",
          name: pattern.name.inspect),
    )
  end
end
