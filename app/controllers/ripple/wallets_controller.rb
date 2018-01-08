require 'connection/request'

module Ripple
  class WalletsController < AccountController

    self.context_resource_class= "Ripples::Models::Wallet"
    self.resource_actions = [:new, :create, :edit, :update, :show, :destroy, :active, :import_secret]
    use_resource!

    include Users::Helpers::SubscriptionRestriction::Controller

    def index
      if params[:archived]
        @wallets = resource_class_constant.deleted
      else
        @wallets = resource_class_constant
      end
      @wallets = @wallets.where(account: current_account).order("updated_at DESC").page(params[:page]).per(20)
      respond_to do |f|
        f.html
        f.js do
          render_table
        end
      end
    end

    def show
      respond_to do |f|
        f.html
        f.js {
          if modal_params_present?
            render_modal
          end
        }
      end
    end

    def create
      restrict_address_creation do
        @wallet.account = current_account
        if @wallet.save
          respond_to do |f|
            f.html { redirect_to ripple_wallets_path, notice: "Success" }
            f.js do
              params[:notification]= { message: "Wallet created!" }
              render_table "/shared/table/reload.js.erb"
            end
          end
        else
          respond_to do |f|
            f.html { render :new }
            f.js do
              if modal_params_present?
                params[:notification]= { message: "Failed to create wallet!", type: "danger" }
                render_modal
              end
            end
          end
        end
      end
    end

    def new
      respond_to do |f|
        f.html
        f.js {
          if modal_params_present?
            render_modal
          end
        }
      end
    end

    def edit
      respond_to do |f|
        f.html
        f.js {
          if modal_params_present?
            render_modal
          end
        }
      end
    end

    def update
      if @wallet.update wallet_params
        respond_to do |f|
          f.html { redirect_to ripple_wallets_path, notice: "Success" }
          f.js do
            params[:notification]= { message: "Wallet updated!" }
            render_table "/shared/table/reload.js.erb"
          end
        end
      else
        respond_to do |f|
          f.html { render :new }
          f.js do
            if modal_params_present?
              params[:notification]= { message: "Failed to update wallet!", type: "danger" }
              render_modal
            end
          end
        end
      end
    end

    def destroy
      if @wallet.destroy
        respond_to do |f|
          f.html { redirect_to ripple_wallets_path, notice: "Wallet is archived!" }
          f.js do
            if table_params_present?
              params[:notification]= { message: "Wallet is sent to archive" }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      end
    end

    def active
      @wallet.update(validated: true)
      respond_to do |f|
        f.html { redirect_to ripple_wallets_path, notice: "Wallet is validated." }
        f.js{  }
      end
    end

    def restore
      if resource_class_constant.restore(params[:id])
        respond_to do |f|
          f.html{ redirect_to ripple_wallets_path(archived: true), notice: "Wallet is restored" }
          f.js do
            if table_params_present?
              params[:notification]= { message: "Wallet restored!" }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      else
      end
    end

    def generate_xrp_testnet_wallet
      connection = ::Connection::Request.new :post, "https://faucet.altnet.rippletest.net/accounts", {}, true
      connection.invoke
      if connection.success?
        wallet = resource_class_constant.create!(
                                                  address: connection.response.account.address,
                                                  secret: connection.response.account.secret,
                                                  balance: BigDecimal.new(connection.response.balance) * 1000000,
                                                  validated: true,
                                                  account: current_account,
                                                  skip_generate_address: true
                                                )
        respond_to do |f|
          message = "Wallet is successfully created."
          f.html { redirect_to ripple_wallets_path, notice: message }
          f.js {
            render_table "/shared/table/reload.js.erb"
          }
        end
      else
        message = "Connection failure."
        respond_to do |f|
          f.html { redirect_to ripple_wallets_path, error: message }
          f.js {
            params[:notification] = { message: message, type: "error" }
            dismiss_modal
          }
        end
      end
    end

    def import_secret
      encrypted_request =
    end

    def wallet_params
      if params[:ripples_models_wallet].present?
        params.require(:ripples_models_wallet).permit(:label)
      end
    end

  end
end