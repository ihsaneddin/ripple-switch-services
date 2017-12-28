module Supports
  module RedisAttributesMapping
    extend ActiveSupport::Concern

    module ClassMethods

      def map_attributes opts={}
        opts= { name: self.name, key: :id, value: :to_json, callback: :after_commit }.merge! opts
        class_eval %{
          def map_to_redis
            $redis.hset(#{opts[:name].to_s}, send('#{opts[:key].to_s}'), send('#{opts[:value].to_s}'))
          end
        }
        send(opts[:callback], :map_to_redis)
      end

      def get(key)
        $redis.hget(self.name, key)
      end

    end

  end
end