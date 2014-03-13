Cashbox::Application.routes.draw do
  resources :bank_accounts

  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations
  resources :categories, except: :show
  resources :bank_accounts, except: [:show, :index]
end
