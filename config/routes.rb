Rails.application.routes.draw do
  devise_for :users, controllers: { tokens: 'api/v1/users/tokens' }
  namespace :api do
    namespace :v1 do
      resources :profiles, only: [:show]
      resources :users, only: [:index, :show]  
      get 'processors/search_from_customers', to: 'processors#search_from_customers'
      resources :processors
      get 'customers/search_from_procedures', to: 'customers#search_from_procedures'
      resources :customers
      resources :procedures
      resources :types, only: [:index]
      resources :licenses, only: [:index]
      resources :statuses, only: [:index]
    end
  end
end
