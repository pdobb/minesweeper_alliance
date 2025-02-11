# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options(
    Rails.application.config.action_mailer.default_url_options)

  root "home#show"

  namespace :games do
    scope module: :new do
      resource :random, controller: :random, only: :create
      resource :custom, controller: :custom, only: %i[new create]
    end
  end
  resources :games, only: %i[index show new create] do
    scope module: :games do
      scope module: :current do
        namespace :board do
          resources :cells, only: [] do
            scope module: :cells do
              resource :reveal, only: :create
              resource :toggle_flag, only: :create
              resource :highlight_neighbors, only: :create
              resource :dehighlight_neighbors, only: :create
              resource :reveal_neighbors, only: :create
            end
          end
        end
      end

      scope module: :just_ended, as: :just_ended do
        scope module: :active_participants do
          resource(
            :current_user,
            controller: :current_user,
            only: %i[show edit update])
        end
        resource :footer, controller: :footer, only: :show
      end
    end
  end

  resource :metrics, only: :show do
    resources :games, only: :show, module: :metrics
  end

  resources :users, only: :show do
    resources :games, only: :show, module: :users
  end
  resource :current_user, only: [] do
    scope module: :current_user do
      resource :account, controller: :account, only: %i[show destroy] do
        scope module: :account do
          resource :username, controller: :username, only: %i[show edit update]
          resource :authentication, controller: :authentication, only: :show
        end
      end

      resource :time_zone_update, only: :create
    end
  end

  resource :about, controller: :about, only: :show

  if App.development?
    namespace :dev_portal, path: :dev do
      resource(
        :toggle_dev_caching,
        controller: :toggle_dev_caching,
        only: :create)
    end

    namespace :ui_portal, path: :ui do
      root "home#show"

      resource :flash_notifications, only: :show
      resource :error_pages, only: :show
      resource(
        :unsupported_browser_test,
        controller: :unsupported_browser_test,
        only: :show)

      resources :patterns do
        scope module: :patterns do
          resource :toggle_flag, only: :create

          resources :resets, only: :create
          resources :exports, only: :create
        end
      end
      namespace :patterns do
        resources :imports, only: %i[new create]
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no
  # exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is
  # live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/400", to: "errors#bad_request", as: :bad_request
  get "/404", to: "errors#not_found", as: :not_found
  get "/406", to: "errors#unsupported_browser", as: :unsupported_browser
  get "/422", to: "errors#unprocessable_entity", as: :unprocessable_entity
  get "/500", to: "errors#internal_server_error", as: :internal_server_error

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  mount MissionControl::Jobs::Engine, at: "/jobs"
end
