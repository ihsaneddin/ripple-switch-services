module Users
  module Models
    class Plan < ApplicationRecord

      include Users::Helpers::Form

      serialize :features, Hash
      
      has_many :subscriptions, :class_name => "Users::Models::Subscription"
      has_many :accounts, :class_name => "Users::Models::Account", through: :subscriptions

      validates :name, uniqueness: true, presence: true, format: { with: /\A[a-z0-9]+\z/i }
      validates :currency, presence: true
      validates :price, numericality: true
      validates :per_period, presence: true, inclusion: { in: ["month", "year"] }

      before_validation :set_default_features
      before_validation :set_per_period

      scope :free, -> { where(free: true) }
      scope :paid, -> { where.not(free: false) }
      scope :active, -> { where(state: ["active", ""]) }

      include AASM

      aasm column: :state do
        state :active, initial: true
        state :inactive

        event :activate do 
          transitions to: :active, from: :inactive
        end

        event :deactivate do 
          transitions to: :inactive, from: :active
        end

      end

      attr_accessor :display_order

      after_initialize do 
        self.display_order||= self.position
      end

      def set_default_features
        self.features||=  {}
        self.features[:max_wallets_count]||= 10
        self.features[:max_api_request_per_second]||= 1
      end

      def max_wallets_count
        Integer(self.features["max_wallets_count"] || self.features[:max_wallets_count])
      end

      def max_api_request_per_second
        Integer(self.features["max_api_request_per_second"] || self.features[:max_api_request_per_second])
      end

      class << self

        def cached_collection 
          Rails.cache.fetch("#{self.cached_name}-collection", expires_in: 1.day ) do 
            self.order("#{self.table_name}.position ASC").load
          end
        end

        def filter params={}
          res = cached_collection
          if params[:name].present?
            res = res.where("name ilike ?", "%#{params[:name]}%")
          end
          if params[:from_time].present?
            from_time= DateTime.parse(params[:from_time]) rescue nil
            res = res.where("updated_at >= ?", from_time) if from_time
          end
          if params[:state].present?
            res = res.where(state: params[:state])
          end
          if params[:to_time].present?
            to_time= DateTime.parse(params[:to_time]) rescue nil
            res = res.where("updated_at <= ?", to_time) if to_time
          end
          if params[:plan_type].present?
            free = params[:plan_type].eql?("Free") ? true : false
            res = res.where(free: free)
          end
          res
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
            new_plan = cached_collection.find_by_name(plan_name) || cached_collection.free.first
            if account.is_a?(Users::Models::Account) && account.persisted? && new_plan.present?
              yield(new_plan) if account.cached_subscriptions.blank?
              if could_be_upgraded?(account.active_plan, new_plan)
                yield(new_plan)
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