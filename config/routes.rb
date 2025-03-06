Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" },
                     path_names: { sign_in: "login" },
                     sign_out_via: [ :delete, :get ]

  root "static_pages#home"
  get "/about", to: "static_pages#about"
  concern :dashboardable do
    get "/", to: "dashboards#index", as: :dashboard
  end

  namespace :career_officer do
    resources :student_profiles, only: [ :index, :show, :edit, :update ] do
      member do
        patch :update_status
      end
    end
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end


  namespace :recruiter do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  namespace :student do
    concerns :dashboardable
    resources :profiles, only: [ :show, :edit, :update ]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  gem "dotenv-rails", groups: [ :development, :test ]
end
