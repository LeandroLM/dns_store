Rails.application.routes.draw do
  namespace :api do
    resources :dns, only: [:create]
  end
end
