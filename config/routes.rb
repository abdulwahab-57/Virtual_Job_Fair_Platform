Rails.application.routes.draw do
  # Zoom OAuth routes
  get "zoom/auth", to: "zoom#auth"
  get "zoom/callback", to: "zoom#callback"

  # Devise routes for user authentication
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    sign_out_via: [ :delete, :get ]
  }

  devise_scope :user do
    get "users/confirm_recruiter", to: "users/confirmations#confirm_recruiter", as: :confirm_recruiter
  end
  # Root route
  root "static_pages#home"

  # Static pages
  get "/about", to: "static_pages#about"

  # Dashboard concern
  concern :dashboardable do
    get "/", to: "dashboards#index", as: :dashboard
  end

  # Career Officer namespace
  namespace :career_officer do
    # Job Fair Arena
    resources :job_fair_arena, only: [ :index, :show ]

    # Meetings management
    resources :meetings do
      member do
        post :add_participant
        delete :remove_participant
        post :start
        post :end
        post :cancel
      end
    end

    resources :student_profiles, only: [ :index, :show, :edit, :update ] do
      member do
        patch :update_status
      end
      collection do
        get :download_profiles
        post :download_profiles
      end
    end
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Recruiter namespace
  namespace :recruiter do
    # Virtual Booth
    resources :virtual_booth, only: [ :index, :show ]

    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Student namespace
  namespace :student do
    # Virtual Booth
    resources :virtual_booth, only: [ :index, :show ]

    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Dotenv gem (for development and test environments)
  gem "dotenv-rails", groups: [ :development, :test ]
end
