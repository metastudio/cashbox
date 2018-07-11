# frozen_string_literal: true

require 'api_constraints'

Cashbox::Application.routes.draw do
  apipie
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
    member do
      put :switch
    end
  end
  get 'organization_wizzard/new_account', to: 'organization_wizzard#new_account', as: :new_account_organization
  get 'organization_wizzard/new_category', to: 'organization_wizzard#new_category', as: :new_category_organization
  post 'organization_wizzard/default_account', to: 'organization_wizzard#create_default_accounts', as: :default_account_organization
  post 'organization_wizzard/default_category', to: 'organization_wizzard#create_default_categories', as: :default_category_organization
  patch 'organization_wizzard/create_accounts', to: 'organization_wizzard#create_accounts', as: :create_accounts_organization
  patch 'organization_wizzard/create_categories', to: 'organization_wizzard#create_categories', as: :create_categories_organization
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
  resources :invitations, only: [:new, :create]
  resources :organization_invitations, only: [:new, :create, :destroy]
  get '/invitation/:token/accept' => 'invitations#accept', as: :accept_invitation
  get '/organization_invitation/:token/resend' => 'organization_invitations#resend', as: :resend_organization_invitation
  get '/unsubscribes/:token' => 'unsubscribes#activate', as: :activate_unsubscribe
  mount ActionCable.server => "/cable"

  # API
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      devise_for :users, skip: :sessions, controllers: { passwords: 'api/v1/passwords' }
      resources :users, only: %i[update destroy] do
        put :update_profile, on: :member
      end
      post :auth_token, to: 'auth_token#create'

      get :user_info, to: 'users#current'
      get :currencies, to: 'base#currencies'
      get :currency_rates, to: 'base#currency_rates'
      resources :organizations, only: %i[show index create update destroy] do
        resources :bank_accounts, only: %i[show index create update destroy]
        resources :categories, only: %i[show index create update destroy]
        resources :customers, only: %i[show index create update destroy]
        resources :transactions, only: %i[show index create update destroy] do
          post :transfer, action: :create_transfer, on: :collection
        end
        resources :members, only: %i[index show update destroy] do
          get :current
        end
        get :member_info, to: 'members#current'
        put :last_visit, to: 'members#update_last_visit'
        resources :invoices, only: %i[index show create update destroy] do
          get :unpaid, on: :collection
          get 'unpaid/count' => :unpaid_count, on: :collection
        end
        get :total_balances, on: :member
        resources :organization_invitations, only: %i[index show create destroy] do
          post :resend, on: :member
        end
        resources :debtors, only: :index
      end
    end
  end
end
