Rails.application.routes.draw do
  devise_for :users, controllers: { tokens: 'api/v1/users/tokens' }
  namespace :api do
    namespace :v1 do
      resource :user, only: [:show]  
      resources :clientes
    end
  end
end
