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
    get :new_account, on: :member
    get :new_category, on: :member
    get :default_account, on: :member
    get :default_category, on: :member
    member do
      put :switch
    end
  end
  resources :statistics, only: :index do
    get :income_by_customers, on: :collection, as: :income_by_customers
    get :expense_by_customers, on: :collection, as: :expense_by_customers
    get :income_by_categories, on: :collection, as: :income_by_categories
    get :expense_by_categories, on: :collection, as: :expense_by_categories
    get :totals_by_customers, on: :collection, as: :totals_by_customers
    get :balances_by_customers, on: :collection, as: :balances_by_customers
    get :balance, on: :collection, as: :balance
    get :customers_chart, on: :collection, as: :customers_chart
  end
  resources :bank_accounts, except: :show do
    put :hide, on: :member
    put :sort, on: :collection
  end
  resources :categories, except: :show
  resources :transactions,  only: [:new, :create, :edit, :update, :destroy] do
    post :transfer, action: :create_transfer, on: :collection
  end
  resources :members, only: [:index, :edit, :update, :destroy]
  resources :customers, except: :show do
    get 'autocomplete', on: :collection
  end
  resources :invoices do
    get 'unpaid', on: :collection
    resources :invoice_items, except: :show
  end
  resources :invitations, only: [:new, :create, :destroy]
  get '/invitation/:token/accept' => 'invitations#accept', as: :accept_invitation
  get '/invitation/:token/resend' => 'invitations#resend', as: :resend_invitation
  mount ActionCable.server => "/cable"
end
