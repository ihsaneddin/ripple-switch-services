module Supports
  module Notifications
    module Builders
      class NotificationBuilder
        
        attr_accessor :sender, :notifiable, :recipients, :subject, :message, :code, :title, :condition_if, 
                      :condition_unless, :on, :record, :mail, :ipn, :common

        NOTIFICATION_CLASS= Supports::Notifications::Models::Notification

        #
        # append opts to attr_accessors
        #
        def initialize opts={}
          opts.each do |key, opt|
            self.send("#{key}=", opt) if respond_to?(key.to_sym)
          end
          self.on||= :after_create
          self.common= { option_broadcast: false } if self.mail.blank? && self.ipn.blank?

          [:sender, :recipients, :message, :subject, :code].each do |_key|
            class_eval %{
              def #{_key}
                #{_key}= instance_variable_get("@#{_key}")
                case #{_key}
                when Proc
                  #{_key}.call(record)
                when Symbol
                  record.try(:send, #{_key})
                when String
                  #{_key}
                end
              end
            }
          end

        end

        #
        # set callback for model
        #
        def set_callbacks model=nil
          self.record||= model
          if record.kind_of?(ActiveRecord::Base)
            record.class.send(self.on || :after_create, "_#{self.on || 'after_create'}_create_notification".to_sym)
          end
        end

        #
        # check if options :if or :unless present
        # if present then check whether notification is created or not
        #
        def allow_notify?
          condition = self.condition_if || self.condition_unless
          return true if condition.nil?
          case condition
          when Proc
            result = condition.call(record)
          when Symbol, String
            result = record.send(condition)
          else
            raise ArgumentError, "You need to supply Proc or String, or Symbol to \`if\` or \`unless`\ option"
          end
          if self.condition_unless
            return !result
          end
          result
        end

        #
        # set notifiable object
        #
        def notifiable
          _notifiable= instance_variable_get("@notifiable")
          case _notifiable
          when Proc
            _notifiable.call(record)
          when Symbol, String
            record.send(_notifiable)
          else
            record
          end
        end

        #
        # define receipt class based on key options
        #
        def receipt_class name
          case name.to_sym
          when :mail
            Supports::Notifications::Models::ReceiptTypes::Mail
          when :ipn
            Supports::Notifications::Models::ReceiptTypes::IPN
          else
            Supports::Notifications::Models::ReceiptTypes::Common
          end
        end

        #
        # check if receipt allowed to be created
        #
        def receipt_condition recipient, opts={}
          cond = opts[:if] || opts[:unless]
          result= true
          return result if cond.nil?
          case cond
          when Proc
            result = cond.call(record, recipient)
          when Symbol, String
            result = record.send(cond)
          else
            cond
          end
          if opts[:unless]
            return !result
          end
          result
        end

        #
        # set receipt options
        #
        def receipt_options(recipient, opts={})
          return {} if opts.blank?
          _opts = { recipient: recipient }
          opts.except(:if, :unless).each do |_key, arg|
            case arg
            when Proc
             _opts[_key]= arg.call(recipient)
            when Hash, String
              _opts[_key]= record.send(arg)
            else
              _opts[_key]= arg
            end
          end
          _opts
        end

        #
        # get receipts list for notifications
        #
        def receipts_list
          receipts = []
          { ipn: self.ipn, mail: self.mail, common: self.common}.compact.each do |name, opts|
            Array(self.recipients).flatten.uniq.compact.each do |recipient|
              if receipt_condition(recipient, opts)
                attrs= receipt_options(recipient, opts)
                receipts << receipt_class(name).new(attrs) if attrs.present?  
              end
            end
          end
          receipts.compact.uniq
        end

        #
        # create notification
        #
        def create
          if allow_notify?
            notification = NOTIFICATION_CLASS.new notifiable: notifiable, body: message, subject: subject, code: code
            receipts= receipts_list
            if receipts.present?
              begin
                ActiveRecord::Base.transaction do
                  if notification.save
                    receipts.each do |rec|
                      rec.notification= notification
                      unless rec.save
                        p rec.errors.full_messages
                        raise ActiveRecord::Rollback
                      end
                    end
                  end
                end
              rescue => e
                p e.message
                p e.backtrace
              end
            end
          end
        end

      end
    end
  end
end