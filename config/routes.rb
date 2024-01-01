Rails.application.routes.draw do
  devise_for :users, controllers: { tokens: 'api/v1/users/tokens' }
  namespace :api do
    namespace :v1 do
      resources :profiles, only: [:show]
      resources :users, only: [:index, :show]  
      resources :processors
      resources :customers
      resources :procedures
    end
  end
end
