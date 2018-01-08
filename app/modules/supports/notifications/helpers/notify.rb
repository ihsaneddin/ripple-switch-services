module Supports
  module Notifications
    module Helpers
      module Notify

        extend ActiveSupport::Concern

        #
        # prepare methods for defined callbacks
        # and set callbacks for each called #notify
        # insert the self object to notification_builder#record= to sync changed attrs
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
          notification_builder.create
        end

        module ClassMethods

          #
          # declare this method on model class that implemented notifications
          #
          def notify opts ={}

            raise ArgumentError, "You need to supply the \`recipients\` option" if opts[:recipients].nil?
            raise ArgumentError "Invalid callbacks. supply callback with one of these options #{valid_callbacks.join(', ')}" unless valid_callbacks.include?(opts[:on])

            validates_receipt_types(opts)

            unless respond_to?(:notifications)
              has_many :notifications, class_name: "Supports::Notifications::Models::Notification", as: :notifiable
              accepts_nested_attributes_for :notifications, allow_destroy: false, reject_if: :all_blank
            end

            unless respond_to?(:_notification_builders)
              class_attribute :_notification_builders, instance_writer: false
              self._notification_builders= Hash.new { |h, k| h[k] = [] }
              attr_accessor :notification_builder_context

              before_validation do
                prepend_notification_builder
              end

              #
              # have to do this as event destroy, really_destroy! do not call before_validation callback
              #
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
          # validates options to make sure required keys is present
          #
          def validates_receipt_types opts={}
            if opts[:mail].present?
              if !opts[:mail].is_a?(Hash) || opts[:mail][:option_email].nil?
                raise ArgumentError, "Invalid type argument. Valid argument is Hash object with keys: \`option_email\`"
              end
            end

            if opts[:ipn].present?
              raise ArgumentError, "Invalid type argument. Valid argument is Hash object with keys: \`option_ipn_key\`, \`option_ipn_url\`" unless opts[:ipn].is_a?(Hash)
              raise ArgumentError, "You need to supply `ipn_key` option" if opts[:ipn][:option_ipn_key].blank?
              raise ArgumentError, "You need to supply `ipn_url` option" if opts[:ipn][:option_ipn_url].blank?
            end
          end

          #
          # append NotificatioBuilder object for initialization
          #
          def notify_each opts={}
            _notification_builders[opts[:on] || :after_create] << Supports::Notifications::Builders::NotificationBuilder.new(opts)
          end

          protected

            def notify_valid_options
              [:if, :unless, :title, :message, :recipients, :notifiable, :retry, :on, :serializer_class, :type]
            end

            #
            # only the record has been create the notification can be build
            # if not it cause loop forever error stack
            #
            def valid_callbacks
              [:after_create, :after_save, :after_update, :after_commit]
            end

            #
            # valid receipt types options
            #
            def valid_types
              [:common, :email, :ipn]
            end

        end

      end
    end
  end
end