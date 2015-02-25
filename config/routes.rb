Cashbox::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'user/registrations' }
  as :user do
    get 'user/profile' => 'user/registrations#edit', as: :user_profile
    put 'user/update_profile' => 'user/registrations#update_profile', as: :update_user_profile
    put 'user/update_account' => 'user/registrations#update', as: :update_user_account
  end

  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    member do
      put :switch
    end
  end
  resources :bank_accounts, except: :index do
    put :hide, on: :member
    put :sort, on: :collection
  end
  resources :categories
  resources :transactions,  only: [:create, :edit, :update, :destroy] do
    post :transfer, action: :create_transfer, on: :collection
  end
  resources :members, only: [:index, :edit, :update]
end
