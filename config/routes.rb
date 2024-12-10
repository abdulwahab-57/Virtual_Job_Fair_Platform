Rails.application.routes.draw do
  # Single devise_for :users declaration
  devise_for :users, sign_out_via: [ :delete, :get ]

  root to: "home#index"

  get "home/dashboard", to: "home#dashboard", as: "home_dashboard"
end
