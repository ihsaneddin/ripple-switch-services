module Users
  module Models
    class Subscription < ApplicationRecord

      include Users::Helpers::Coinspayment

      self.caches_suffix_list= ['collection', 'need-coinspayment-status-collection']

      belongs_to :account, class_name: "Users::Models::Account", touch: true
      belongs_to :plan, class_name: "Users::Models::Plan", touch: true

      scope :inactive, -> { where(state: "expired").recent }

      include AASM

      aasm column: :state do
        state :draft, initial: true
        state :canceled
        state :waiting_confirmation
        state :active
        state :expired

        event :cancel do
          transitions to: :canceled, from: :draft
        end

        event :wait_for_confirmation do 
          transitions to: :waiting_confirmation, from: :draft
        end

        event :confirm, after: :void_previous_subscription_and_set_expired_time do 
          transitions to: :active, from: :waiting_confirmation
        end

        event :expire do
          transitions :from => :active, :to => :expired
        end
      
      end

      def void_previous_subscription_and_set_expired_time
        account.subscriptions.where.not(id: self.id).update_all(state: "expired")
        unless plan.free?
          if self.update_attribute expired_at: (DateTime.now + 1.try(plan.per_period))
            Users::Workers::SubscriptionWorker.perform_at(self.expired_at, self.id)
          end
        end
      end

      def expiring!
        expire! if expired_at > DateTime.now
      end

      def expire!
        self.update state: true
      end

      class << self

        def accepted_coins_rates
          #Rails.cache.fetch("#{cache_prefix}-accepted-coins", expires_in: 1.month) do 
          Coinpayments.rates(accepted: 1)
          #end
        end

        def cached_draft_collection
          
        end

        def cached_wait_for_confirmation_collection
          
        end

        def need_coinspayment_status_collection
          Rails.cache.fetch("#{self.cached_name}-need-coinspayment-status-collection", expires_in: 1.day) do 
            where(state: ["draft", "waiting_confirmation"]).order("created_at ASC").load
          end
        end

      end

    end
  end
end