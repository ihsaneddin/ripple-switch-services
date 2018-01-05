module Supports
  module Notifications
    module Builders
      class NotificationBuilder
        
        attr_accessor :sender, :notifiable, :recipients, :subject, :message, :title, :condition_if, 
                      :condition_unless, :on, :record, :mail, :ipn, :common

        NOTIFICATION_CLASS= Supports::Notifications::Models::Notification

        def initialize opts={}
          self.sender = opts[:sender]
          self.notifiable= opts[:notifiable]
          self.recipients= opts[:recipients]
          self.subject= opts[:subject]
          self.message= opts[:message]
          self.on= opts[:on] || :after_create
          self.condition_unless= opts[:unless]
          self.condition_if= opts[:if]
          self.ipn= opts[:ipn]
          self.mail= opts[:mail]
          self.common= opts[:common]
          self.common= {} if self.mail.blank? && self.ipn.blank?

          [:sender, :recipients, :message, :subject].each do |_key|
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

        def set_callbacks model=nil
          self.record||= model
          if record.kind_of?(ActiveRecord::Base)
            record.class.send(self.on || :after_create, "_#{self.on || 'after_create'}_create_notification".to_sym)
          end
        end

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

        def create
          if allow_notify?
            notification = NOTIFICATION_CLASS.new notifiable: notifiable, body: message, subject: subject    
            if notification.save
              receipts_list.each do |rec|
                rec.notification= notification
                rec.save
              end
            end
          end
        end

      end
    end
  end
end