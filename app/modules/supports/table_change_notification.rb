module Supports
  module TableChangeNotification
    
    extend ActiveSupport::Concern

    def notify_change
      if notify_condition
        connection.execute "NOTIFY #{channel}, #{connection.quote self.to_s}"
      end
    end

    def notify_condition
      self.changed?
    end

    module ClassMethods

      def notify_changes_after options=[]
        options.eeach do |option|
          send("after_#{option}", :notify_change)
        end
      end

      def channel
        "channel-#{self.table_name}"
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