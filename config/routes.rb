# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options(
    Rails.application.config.action_mailer.default_url_options)

  root "home#show"

  resources :games, only: %i[index show new create] do
    scope module: :games do
      resource :user, only: %i[edit update]

      scope module: :current do
        namespace :board do
          resources :cells, only: [] do
            scope module: :cells do
              resource :reveal, only: :create
              resource :toggle_flag, only: :create
              resource :highlight_neighbors, only: :create
              resource :reveal_neighbors, only: :create
            end
          end
        end
      end
    end
  end
  resource :random_game, only: :create
  resource :custom_game, only: %i[new create]

  resource :metrics, only: :show do
    resources :games, only: :show, module: :metrics
  end

  resources :users, only: :show do
    resources :games, only: :show, module: :users
  end
  resource :current_user, only: [] do
    resource :time_zone_update, only: :create, module: :current_user
  end

  resource :about, controller: :about, only: :show

  if App.development?
    namespace :ui_portal, path: :ui do
      root "home#show"

      resource :flash_notifications, only: :show

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

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
