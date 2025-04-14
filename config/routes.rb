Rails.application.routes.draw do
  # Users
  get "/users", to: "users#index", as: "users"
  get "/users/:id", to: "users#show", as: "user"

  # Messages
  get "/messages", to: "messages#index", as: "messages"
  get "/messages/new", to: "messages#new", as: "new_message"
  post "/messages", to: "messages#create"

  # Search Profiles
  get "/search_profiles", to: "search_profiles#index", as: "search_profiles"
  resources :messages, only: [ :index ]
  mount ActionCable.server => "/cable"
  resources :messages, only: [:index, :create]
end
