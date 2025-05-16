Rails.application.routes.draw do
  # Root route
  root "static_pages#home"

  # Static pages
  get "/about", to: "static_pages#about"

  # Inbox and messaging routes
  get "/inbox", to: "inbox#index", as: :inbox
  resources :conversations, only: [ :index, :create ] do
    resources :messages, only: [ :create ]
  end
  # Redirect conversation show path to inbox with conversation_id
  get "/conversations/:id", to: redirect { |params, request| "/inbox?conversation_id=#{params[:id]}" }

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
    resources :job_fair_arena, only: [ :index, :show ]

    # GitHub Analytics routes (flat, not nested)
    get "github_analyzer/rankings", to: "github_analyzer#rankings", as: :github_analyzer_rankings
    get "github_analyzer/skills", to: "github_analyzer#skills", as: :github_analyzer_skills
    get "github_analyzer/activity", to: "github_analyzer#activity", as: :github_analyzer_activity
    get "github_analyzer/view_report/:id", to: "github_analyzer#view_report", as: :github_analyzer_view_report
    get "github_analyzer/download_report/:id", to: "github_analyzer#download_report", as: :github_analyzer_download_report
    post "github_analyzer/evaluate/:id", to: "github_analyzer#evaluate", as: :github_analyzer_evaluate
    post "github_analyzer/analyze_github/:id", to: "github_analyzer#analyze_github", as: :github_analyzer_analyze_github
  end

  # Student namespace
  namespace :student do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
    resources :job_fair_arena, only: [ :index, :show ]
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
  get "analytics/api/chart-data/:chart_type", to: "analytics#api_chart_data", as: :analytics_chart_data

  # GitHub Analysis routes
  namespace :github_analyzer do
    get "rankings", to: "github_analyzer#index"
    get "view_report/:id", to: "github_analyzer#view_report", as: :view_report
    get "download_report/:id", to: "github_analyzer#download_report", as: :download_report
    post "evaluate/:id", to: "github_analyzer#evaluate", as: :evaluate
    post "analyze_github/:id", to: "github_analyzer#analyze_github", as: :analyze_github
  end
end
