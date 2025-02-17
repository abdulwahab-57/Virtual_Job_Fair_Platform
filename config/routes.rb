Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: { registrations: "users/registrations" },
                     path_names: { sign_in: "login" },
                     sign_out_via: [ :delete, :get ]

  # Static pages
  root "static_pages#home"
  get "/about", to: "static_pages#about"

  # Dashboard concern
  concern :dashboardable do
    get "/", to: "dashboards#index", as: :dashboard
  end

  # Namespaces for different user roles
  namespace :career_officer do
    concerns :dashboardable
    resource :profile, only: [ :show, :edit, :update ] # Use `resource` for singular profile
  end

  namespace :recruiter do
    concerns :dashboardable
    resource :profile, only: [ :show, :edit, :update ] # Use `resource` for singular profile
  end

  namespace :student do
    concerns :dashboardable
    resource :profile, only: [ :show, :edit, :update ] # Use `resource` for singular profile
  end
end
