Rails.application.routes.draw do
  # Single devise_for :users declaration
  devise_for :users, path_names: { sign_in: "login" }, sign_out_via: [ :delete, :get ]

  root "static_pages#home"
  get "/about", to: "static_pages#about"

  concern :dashboardable do
    get "/", to: "dashboards#index"
  end

  namespace :career_officer do
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
end
