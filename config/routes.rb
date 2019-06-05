Rails.application.routes.draw do
  namespace :api do
    resources :dns, only: :create do
      post :list, on: :collection
    end
  end
end
