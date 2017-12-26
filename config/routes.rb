require 'sidekiq/web'

Rails.application.routes.draw do
  #use_doorkeeper
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # sidekiq Routes
  mount Sidekiq::Web => '/sidekiq'

  # api routes
    #namespace :api do 
  #  namespace :v1 do
      #
      # oauth2 implementation routes for grant password and refresh_token
      #
  #    resources :sessions, only: [:create, :update], param: :token
  #  end
  #end
  mount Api::Base => '/'

  # web socket server
  mount ActionCable.server => '/cable'

  # root path
  root to: 'home#index'

  # account's routes

  devise_for :accounts, path: 'auth', skip: [:confirmations, :registrations, :passwords], class_name: "Users::Models::Account",
             path_names: {sign_in: 'login', sign_out: 'logout',},
             controllers: {sessions: 'sessions',}

  # custom token login
  devise_scope :account do
    get 'sessions/token', to: "sessions#token", as: :token_session_account
  end

  namespace :ripple do 
    resources :wallets, except: [:edit, :update] do 
      member do 
        put :active
        put :restore
      end
      collection do 
        unless Rails.env.production?
          post :generate_xrp_testnet_wallet
        end
      end
      resources :transactions, only: [:new, :create] do 
        member do 
          put :complete
        end
      end
    end
  end

  resources :plans, only: [:index], param: :name do 
    resources :subscriptions, only: [:new, :create, :show], param: :name do 
      member do 
        put :cancel
      end
    end
  end

  resources :pins, only: [:update]

  # static pages
  get "/pages/*page" => "pages#show", as: :page

  # admin's routes

  devise_for :admins, path: "administrator", skip: [:confirmations, :registrations], class_name: "Administration::Models::Admin",
              path_names: { sign_in: "login", sign_out:  "logout"},
              controllers: { sessions: "admin/sessions", passwords: "admin/profile" }

  namespace :admin, path: "administrator" do 
    
    get "", to: "dashboards#index"

    resources :dashboards, path: "dashboard", only: :index do 
      collection do 
        get :accounts
        get :subscriptions
      end
    end
    resources :accounts, only: [:index, :show], param: :username
    resources :plans, path: "packages", param: :name do 
      member do 
        put :activate
        put :deactivate
      end
    end
    resources :subscriptions, only: [:index, :show], param: :name do 
      member do 
        put :cancel
        put :confirm
        put :expire
      end
    end
    
    resources :profiles, path: "profile", only: [:edit, :update]

    resources :transactions, only: [:index, :show]
    resources :wallets, only: [:index, :show]

  end


end
