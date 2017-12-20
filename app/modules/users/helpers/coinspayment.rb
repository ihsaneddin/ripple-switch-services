module Users
  module Helpers
    module Coinspayment

      extend ActiveSupport::Concern

      included do 

        validates :coin, presence: true, inclusion: { in: Users::Models::Plan.accepted_coins, allow_blank: true }, unless: Proc.new{|subs| subs.plan.try(:free) }
        #validates :amount, presence: true, numericality: { greater_than: 0 }

        before_create :submit_payment, unless: Proc.new{|subs| subs.plan.try(:free?) }
        before_validation :generate_name

      end

      def generate_name
        self.name||= loop do 
          random_string = SecureRandom.urlsafe_base64(5, false)
          break random_string unless self.class.exists?(name: random_string)
        end
      end

      def submit_payment
        begin
          transaction = Coinpayments.create_transaction(plan.price, 'USD', self.coin)
          if transaction.is_a? String
            self.errors.add(:coin, transaction)
            throw :abort
          else
            self.amount= transaction.amount.to_d
            self.txn_id= transaction.txn_id
            self.payment_address= transaction.address
            self.qrcode_url= transaction.qrcode_url
            self.status_url= transaction.status_url
          end
        rescue Net::ReadTimeout => e
          self.errors.add(:coin, "Request timeout.")
          throw :abort
        end
      end

      def fetch_tx_info reload= false
        @tx_info= nil if reload
        @tx_info||= begin
                      Coinpayments.get_tx_info(self.txn_id)
                    rescue => e
                      Hashie::Mash.new
                    end
      end

    end
  end
end