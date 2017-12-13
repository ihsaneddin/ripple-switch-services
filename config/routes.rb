require 'sidekiq/web'

Rails.application.routes.draw do
  #use_doorkeeper
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount Sidekiq::Web => '/sidekiq'

  root to: 'home#index'

  devise_for :accounts, path: 'auth', skip: [:confirmations], class_name: "Users::Models::Account",
             path_names: {sign_in: 'login', sign_out: 'logout', password: 'passwords'},
             controllers: {sessions: 'sessions', passwords: 'passwords'}

  # custom token login
  devise_scope :account do
    get 'sessions/token', to: "sessions#token", as: :token_session_account
  end

  #namespace :api do 
  #  namespace :v1 do
      #
      # oauth2 implementation routes for grant password and refresh_token
      #
  #    resources :sessions, only: [:create, :update], param: :token
  #  end
  #end

  mount Api::Base => '/'

  namespace :ripple do 
    resources :wallets, except: [:edit, :update] do 
      member do 
        put :active
        put :restore
      end
      resources :transactions, only: [:new, :create] do 
        member do 
          put :complete
        end
      end
    end
  end

  resources :pins, only: [:update]

  # static pages
  get "/pages/*page" => "pages#show", as: :page

end
