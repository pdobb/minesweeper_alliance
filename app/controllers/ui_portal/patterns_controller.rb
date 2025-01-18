# frozen_string_literal: true

# :reek:InstanceVariableAssumption

class UIPortal::PatternsController < UIPortal::BaseController
  before_action :require_pattern, only: %i[show edit update destroy]

  def index
    @view = UIPortal::Patterns::Index.new(base_arel: Pattern.by_most_recent)
  end

  def show
    @view = UIPortal::Patterns::Show.new(@pattern)
  end

  def new
    @view = UIPortal::Patterns::New.new(context: layout)
  end

  # :reek:TooManyStatements
  def create
    settings = Pattern::Settings.new(new_pattern_params[:settings])
    pattern = Pattern.new(name: new_pattern_params[:name], settings:)

    if pattern.save
      store_pattern_settings(settings)
      redirect_to({ action: :show, id: pattern })
    else
      @view = UIPortal::Patterns::New.new(pattern, context: layout)
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
  end

  def update
    @pattern.attributes = edit_pattern_params
    if @pattern.save
      redirect_to({ action: :show, id: @pattern })
    else
      render(:edit)
    end
  end

  # :reek:TooManyStatements
  # :reek:DuplicateMethodCall

  def destroy # rubocop:disable Metrics/MethodLength
    @pattern.destroy

    respond_to do |format|
      format.html { redirect_to_index_after_destroy(@pattern) }
      format.turbo_stream {
        # Not sure of a good way around this hack... But we want to use a Turbo
        # Stream for destruction from the Index page, while using redirect for
        # destruction from the Show page.
        if request.referer.include?(ui_portal_pattern_path(@pattern))
          redirect_to_index_after_destroy(@pattern)
        else # Index page
          render(turbo_stream: turbo_stream.remove(@pattern))
        end
      }
    end
  end

  private

  def require_pattern
    if (pattern = Pattern.for_id(params[:id]).take)
      @pattern = pattern
    else
      redirect_to(
        { action: :index }, alert: t("flash.not_found", type: "Pattern"))
    end
  end

  def new_pattern_params
    params.expect(
      pattern: [
        :name,
        { settings: %i[width height] },
      ])
  end

  def edit_pattern_params
    params.expect(pattern: %i[name])
  end

  def store_pattern_settings(settings)
    layout.store_http_cookie(
      UIPortal::Patterns::New::SettingsForm::STORAGE_KEY,
      value: settings.to_json)
  end

  def redirect_to_index_after_destroy(pattern)
    redirect_to(
      { action: :index },
      notice:
        t("flash.successful_destroy_with_name",
          type: "Pattern",
          name: pattern.name.inspect))
  end
end
