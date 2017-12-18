Coinpayments.configure do |config|
  config.merchant_id     = ENV['COIN_PAYMENTS_MERCHANT_ID']
  config.public_api_key  = ENV['COIN_PAYMENTS_PUBLIC_KEY']
  config.private_api_key = ENV['COIN_PAYMENTS_PRIVATE_KEY']
end
