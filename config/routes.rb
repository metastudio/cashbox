Cashbox::Application.routes.draw do
  resources :categories

  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    resources :invoices,   except: [:show, :index]
    resources :categories, except: :show
  end
end
