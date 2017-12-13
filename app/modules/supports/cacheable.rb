module Supports
  module Cacheable
    
    extend ::ActiveSupport::Concern

    included do 
      
      class_attribute :caching_name, :caches_suffix_list, :object_caches_suffix

      self.caches_suffix_list= ['collection']
      self.object_caches_suffix= []
      
      after_commit :clear_cache!
      after_destroy :clear_cache!    

    end

    module ClassMethods
      
      def cached_name(reload=false)
        if reload
          self.caching_name= "#{self.name.demodulize.parameterize}-cached"
        else
          self.caching_name||= "#{self.name.demodulize.parameterize}-cached"
        end
      end

      def cached_collection(options={ condition: {} })
        if options[:condition].present?
          Rails.cache.delete(self.cached_name)
        end
        Rails.cache.fetch("#{self.cached_name}-collection", expires_in: 1.day ) do 
          self.order("#{self.table_name}.updated_at DESC").where(options[:condition]).load
        end
      end

    end

    protected

      #
      # clear cache if present
      #
      def clear_cache!
        self.class.caches_suffix_list.each do |cache_suffix|
          Rails.cache.delete("#{self.class.cached_name}-#{cache_suffix}")            
        end
        self.class.object_caches_suffix.each do |cache_suffix|
          Rails.cache.delete("#{self.class.cached_name}-#{self.id}-#{cache_suffix}")            
        end
      end
    
  end
end