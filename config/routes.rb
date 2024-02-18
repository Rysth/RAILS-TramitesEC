Rails.application.routes.draw do
  devise_for :users, controllers: { tokens: 'api/v1/users/tokens' }
  namespace :api do
    namespace :v1 do
      get 'payment_types/index'
      get 'payment_types/show'
      resources :profiles, only: [:show]
      resources :users, only: [:index, :show]  
      get 'processors/search_processors', to: 'processors#search_processors'
      resources :processors  do
        get 'generate_excel', on: :collection
      end
      get 'customers/search_from_procedures', to: 'customers#search_from_procedures'
      resources :customers
      resources :procedure_types, only: [:index]
      resources :license_types, only: [:index]
      resources :licenses, only: [:index]
      resources :statuses, only: [:index]
      resources :procedures
      resources :payment_types, only: [:index, :show]
      resources :payments, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
