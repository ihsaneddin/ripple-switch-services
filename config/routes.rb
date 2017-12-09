Rails.application.routes.draw do
  #use_doorkeeper
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'dashboard#index'

  devise_for :accounts, path: 'auth', skip: [:confirmations], class_name: "Users::Models::Account",
             path_names: {sign_in: 'login', sign_out: 'logout', password: 'passwords'},
             controllers: {sessions: 'sessions', passwords: 'passwords'}

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

end
