Rails.application.routes.draw do
  # Root route
  root "static_pages#home"

  # Static pages
  get "/about", to: "static_pages#about"

  # Dashboard concern
  concern :dashboardable do
    get "/", to: "dashboards#index", as: :dashboard
  end

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

  # Zoom OAuth routes
  get "zoom/auth", to: "zoom_auth#auth"
  get "zoom/callback", to: "zoom_auth#callback"
  delete "zoom/disconnect", to: "zoom_auth#disconnect"


  # Career Officer namespace
  namespace :career_officer do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]

    resources :student_profiles, only: [ :index, :show, :edit, :update ] do
      member do
        patch :update_status
      end
      collection do
        get :download_profiles
        post :download_profiles
      end
    end

    resources :meetings, only: [ :index, :new, :create ]
    resources :job_fair_arena, only: [ :index, :show ]
  end

  # Recruiter namespace
  namespace :recruiter do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Student namespace
  namespace :student do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
