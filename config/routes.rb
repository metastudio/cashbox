Cashbox::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'user/registrations' }
  as :user do
    get 'user/profile' => 'users/registrations#edit', as: :user_profile
    put 'user/update_profile' => 'users/registrations#update_profile', as: :update_user_profile
    put 'user/update_account' => 'users/registrations#update', as: :update_user_account
    post 'invitation/create_user' => 'users/registrations#create_user_from_invitation', :as => 'create_user_from_invitation'
  end

  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    resources :statistics, only: :index
    member do
      put :switch
    end
  end
  resources :bank_accounts, except: :show do
    put :hide, on: :member
    put :sort, on: :collection
  end
  resources :categories, except: :show
  resources :transactions,  only: [:create, :edit, :update, :destroy] do
    post :transfer, action: :create_transfer, on: :collection
  end
  resources :members, only: [:index, :edit, :update]
  resources :customers, except: :show do
    get 'autocomplete', on: :collection
  end
  resources :invitations, only: [:index, :new, :create, :destroy]
  get '/invitation/:token/accept' => 'invitations#accept', as: :accept_invitation
  get '/invitation/:token/resend' => 'invitations#resend', as: :resend_invitation
end
