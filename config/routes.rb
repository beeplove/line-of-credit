Rails.application.routes.draw do
  resources :accounts, only: [:create, :show] do
    member do
      put :deposit
      put :withdraw
      get :statement
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
