module IPN
  module Helpers
    module Notify
      
      extend ActiveSupport::Concern

#      included do 
#        
#        class_attribute :_notification_builders, instance_writer: false
#        self._notification_builders= Hash.new { |h, k| h[k] = [] }

#        attr_accessor :notification_builder_context

#        after_initialize do 
#          prepend_notification_builder
#        end

#      end

      #
      # prepare methods for defined callbacks
      # and set callbacks for each called #notify
      #
      def prepend_notification_builder
        self.class._notification_builders.keys.each do |_callback|
          class_eval %{
            def _#{_callback}_create_notification
              self.class._notification_builders['#{_callback}'.to_sym].each do |nb|
                self.notification_builder_context= nb
                self.notification_builder_context.record= self
                _create_notification
              end
            end
          }
        end
        self.class._notification_builders.each do |_callback, nbs|
          nbs.each{|nb| nb.set_callbacks(self) }
        end
      end

      #
      # create notification object
      #
      def _create_notification(notification_builder=nil)
        notification_builder||= self.notification_builder_context
        notification_builder.create_notification
      end

      module ClassMethods
        
        #
        # declare this method on model class that implemented IPN
        #
        def notify opts ={}

          raise ArgumentError, "You need to supply the \`recipients\` option" if opts[:recipients].nil?
          #raise ArgumentError, "You need to supply the \`notifiable\` option" if opts[:notifiable].nil?
          raise ArgumentError "Invalid callbacks. supply callback with one of these options #{valid_callbacks.join(', ')}" unless valid_callbacks.include?(opts[:on])

          unless respond_to?(:notifications)
            has_many :notifications, class_name: "IPN::Models::Notification", as: :notifiable
            accepts_nested_attributes_for :notifications, allow_destroy: false, reject_if: :all_blank
          end
          unless respond_to?(:_notification_builders)
            class_attribute :_notification_builders, instance_writer: false
            self._notification_builders= Hash.new { |h, k| h[k] = [] }
            attr_accessor :notification_builder_context
            
            before_validation do 
              prepend_notification_builder
            end

            before_destroy do 
              self.class._notification_builders.keys.each do |_callback|
                unless respond_to?("_#{_callback}_create_notification".to_sym)
                  prepend_notification_builder
                  break
                end
              end
            end

          end

          notify_each(opts)

        end

        #
        # append NotificatioBuilder object for initialization
        #
        def notify_each opts={}
          _notification_builders[opts[:on] || :after_create] << IPN::Builders::NotificationBuilder.new(opts)
        end

        protected

          def notify_valid_options
            [:if, :unless, :title, :message, :recipients, :notifiable, :retry, :on, :serializer_class]
          end

          def valid_callbacks
            [:after_create, :after_save, :after_update, :after_commit]
          end

      end

    end
  end
end