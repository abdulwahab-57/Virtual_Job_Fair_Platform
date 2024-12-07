Rails.application.routes.draw do
  devise_for :users
  root "home#index" # Or any other controller action as the root

  # Any custom routes for your application
end
