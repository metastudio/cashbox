Cashbox::Application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations
  resources :bank_accounts, except: [:show, :index]
  resources :categories,    except: :show
  resources :transactions,  only: [:create, :destroy]
end
