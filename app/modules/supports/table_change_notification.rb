module Supports
  module TableChangeNotification
    
    extend ActiveSupport::Concern

    def notify_channel
      if should_notify?
        self.class.connection.execute "NOTIFY #{self.class.channel}, #{self.class.connection.quote self.to_s}"
      end
    end

    def should_notify?
      self.changed?
    end

    module ClassMethods

      def notify_changes_after options=[]
        options = Array(options)  unless options.is_a?(Array)
        options.each do |option|
          send("after_#{option}", :notify_channel)
        end
      end

      def channel
        "channel_#{self.table_name}"
      end

      def on_table_change &block
        connection.execute "LISTEN #{channel}"
        loop do 
          connection.raw_connection.wait_for_notify do |event, pid, record|
            yield record
          end
        end
        ensure
          connection.execute "UNLISTEN #{channel}"
      end

    end

  end
end