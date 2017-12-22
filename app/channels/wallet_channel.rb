class WalletChannel < ApplicationCable::Channel

  def subscribed
    stream_from "wallet-#{params[:wallet_address]}"
  end

end