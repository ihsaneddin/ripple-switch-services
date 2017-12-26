module Users
  module Helpers
    module Form

      extend ActiveSupport::Concern

      module ClassMethods

        def plan_rates
          return Rails.cache.fetch("plan_rates") if Rails.cache.fetch("plan_rates")
          rates||= Coinpayments.rates(accepted: 1)
          plans = Users::Models::Plan.cached_collection

          usd = rates.delete("USD")
          rates.delete_if { |_k, v| v.accepted == 0 }

          plan_rates = {}

          plans.each do |plan|
            next if plan.price <= 0
            plan_rates[plan.name.to_sym] = {}
            rates.each do |coin_name, info| 
              plan_rates[plan.name.to_sym][coin_name.to_sym]= {}
              plan_rates[plan.name.to_sym][coin_name.to_sym][:rate_btc]= info.rate_btc
              plan_price_to_btc = Float(usd.rate_btc) * Float(plan.price)
              plan_rates[plan.name.to_sym][coin_name.to_sym][:rate] = plan_price_to_btc / Float(info.rate_btc)
              plan_rates[plan.name.to_sym][coin_name.to_sym][:name] = info.name
            end
          end
          if Rails.env.development?
            Rails.cache.fetch("plan_rates", expires_in: 1.day) do 
              Hashie::Mash.new(plan_rates)
            end
          else
            Hashie::Mash.new(plan_rates)
          end
        end

        def accepted_coins
          Rails.cache.fetch("plan-accepted-coins", expires_in: 1.day) do 
            Coinpayments.rates(accepted: 1).delete_if { |_k, v| v["accepted"] == 0 }.keys
          end
        end

      end

    end
  end
end