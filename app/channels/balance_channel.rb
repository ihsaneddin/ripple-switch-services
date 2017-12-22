class BalanceChannel < ApplicationCable::Channel

  def subscribed
    stream_from "balance-#{params[:account_id]}"
  end

end