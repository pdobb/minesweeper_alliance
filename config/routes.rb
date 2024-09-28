# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#show"

  get "about" => "home#about"

  resources :games, only: %i[index show new create] do
    scope module: :games do
      resources :boards, only: :none do
        scope module: :boards do
          resources :cells, only: :none do
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
  scope "/games", module: :games do
    resource :random, only: :create, as: :random_game
    resources :customs, only: :new, as: :custom_game
    resources :customs, only: :create, as: :custom_games
  end

  resources :users, only: %i[show edit update]

  if App.development?
    namespace :ui_portal, path: :ui do
      root "home#show"

      get "flash_notifications" => "home#flash_notifications"

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
