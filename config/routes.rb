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

  # Analytics routes
  get "analytics", to: "analytics#index", as: :analytics
  get "analytics/student/:id", to: "analytics#student_analytics", as: :student_analytics
  get "analytics/recruiter/:id", to: "analytics#recruiter_analytics", as: :recruiter_analytics
  get "analytics/dashboard", to: "analytics#dashboard", as: :analytics_dashboard

  # Enhanced Analytics routes
  get "enhanced-analytics/student/:id", to: "enhanced_analytics#student_dashboard", as: :enhanced_analytics_student_dashboard
  get "enhanced-analytics/recruiter/:id", to: "enhanced_analytics#recruiter_dashboard", as: :enhanced_analytics_recruiter_dashboard
  get "enhanced-analytics/career-officer", to: "enhanced_analytics#career_officer_dashboard", as: :enhanced_analytics_career_officer_dashboard
  get "enhanced-analytics/api/chart-data/:chart_type", to: "enhanced_analytics#api_chart_data", as: :enhanced_analytics_chart_data
end
