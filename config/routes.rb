Cashbox::Application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    resources :categories, except: :show
  end
end
