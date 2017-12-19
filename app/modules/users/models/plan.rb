module Users
  module Models
    class Plan < ApplicationRecord

      include Users::Helpers::Form

      serialize :features, Hash
      
      has_many :subscriptions, :class_name => "Users::Models::Subcription"
      has_many :accounts, :class_name => "Users::Models::Account", through: :subscriptions

      validates :name, uniqueness: true, presence: true
      validates :currency, presence: true
      validates :price, numericality: true
      validates :per_period, presence: true, inclusion: { in: ["month", "year"] }

      before_validation :set_default_features
      before_validation :set_per_period

      scope :free, -> { where(free: true) }

      def set_default_features
        self.features||=  {
                            max_wallets_count: 10,
                            max_api_request_per_second: 1
                          }
      end

      class << self

        def cached_collection 
          Rails.cache.fetch("#{self.cached_name}-collection", expires_in: 1.day ) do 
            self.order("#{self.table_name}.display_order ASC").load
          end
        end

      end

      def set_per_period
        self.per_period||= "month"
      end

      module Subscriptions

        extend ActiveSupport::Concern

        def could_be_upgraded_to? prop_plan
          self.price < prop_plan.price
        end

        module ClassMethods

          def create_subscription_for(account, plan_name)
            valid_for_subscription?(account, plan_name) do |prepared_plan|
              subscription = prepared_plan.subscriptions.new account: account
              subscription.save
              return subscription
            end
          end

          def valid_for_subscription? account, plan_name
            new_plan = cached_collection.find_by_name(plan_name)
            if account.is_a?(Users::Models::Account) && account.persisted? && new_plan.present?
              yield(account, new_plan) if account.cached_subscriptions.blank?
              if account.active_plan && could_be_upgraded?(account.active_plan, plan)
                yield(account, new_plan)
              end
            end
          end

          def could_be_upgraded?(prev_plan, prop_plan)
            prev_plan.price < prop_plan.price
          end

        end

      end

      include Users::Models::Plan::Subscriptions

    end
  end
end