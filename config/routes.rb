Cashbox::Application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations
  resources :bank_accounts, except: [:show, :index]
  resources :categories
  resources :transactions,  only: [:create, :edit, :update, :destroy]
  resources :users, only: [:index] do
    member do
      get :edit_role
      put :update_role
    end
  end
end
