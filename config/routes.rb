Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations"
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
    resources :student_profiles, only: [ :index, :show, :edit, :update ] do
      member do
        patch :update_status
      end
    end
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
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

  # Dotenv gem (for development and test environments)
  gem "dotenv-rails", groups: [ :development, :test ]
end
