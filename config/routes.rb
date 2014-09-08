Cashbox::Application.routes.draw do
  devise_for :users
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    member do
      put :switch
    end
  end
  resources :bank_accounts, except: [:show, :index]
  resources :categories
  resources :transactions,  only: [:create, :edit, :update, :destroy]
  resources :members, only: [:index, :edit, :update]
  resource :invitation, only: [:new, :create] do
    member do
      get :accept
      post :create_user
    end
  end
end
