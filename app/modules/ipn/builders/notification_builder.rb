module IPN
  module Builders
    class NotificationBuilder
      
      attr_accessor :notifiable, :recipients, :message, :title, :condition_if, :condition_unless, :on, :retry, :serializer_class, :record

      NOTIFICATION_CLASS= IPN::Models::Notification

      def initialize opts={}
        self.notifiable= opts[:notifiable]
        self.recipients= opts[:recipients]
        self.message= opts[:message]
        self.on = opts[:on] || :after_create
        self.condition_if = opts[:if]
        self.condition_unless = opts[:unless]
        self.retry = opts[:retry]
        self.serializer_class= opts[:serializer_class]
      end

      #
      # we set callbacks on model class to call #create_notification method
      #
      def set_callbacks(model=nil)
        self.record||= model
        if record.kind_of?(ActiveRecord::Base)
          record.class.send(self.on || :after_create, "_#{self.on || 'after_create'}_create_notification".to_sym)
        end
      end

      #
      # check whether the condition is satisfied to generate notification
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
      # set notifiable for notification object
      #
      def set_notifiable
        case self.notifiable
        when Proc
          self.notifiable.call(record)
        when Symbol, String
          record.send(self.notifiable)
        else
          record
        end
      end

      #
      # set recipients object
      #
      def set_recipients
        case self.recipients
        when Proc
          res= self.recipients.call(record)
        when Symbol, String
          res= record.send(self.recipients)
        when Array
          res= self.recipients
        end
        res = res.is_a?(Array) ? res : Array(res)
        res.map{|rec| IPN::Models::Recipient.new(recipient: rec, retry: set_retry) }
      end

      #
      # set message for notification object
      #
      def set_message
        case self.message
        when Proc
          self.message.call(record)
        when Symbol, String
          record.send(self.message)
        end
      end

      #
      # set notification title
      #
      def set_title
        case self.title
        when Proc
          self.title.call(record)
        when Symbol, String
          record.send(self.title)
        end
      end

      #
      # set how many times notification send in case error happen when delivering notification 
      #
      def set_retry
        self.retry.to_i
      end

      #
      # set serializer class
      #
      def set_serializer_class
        self.serializer_class
      end

      def create_notification
        if allow_notify?
          notification = NOTIFICATION_CLASS.new notifiable: set_notifiable, message: set_message, retry: set_retry, serializer_class: set_serializer_class        
          set_recipients.each {|rec| notification.recipients << rec}
          notification.save
        end
      end

    end
  end
end