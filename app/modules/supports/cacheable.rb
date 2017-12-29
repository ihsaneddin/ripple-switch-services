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

      #
      # define cached relationship object/collections
      #
      def cached_relationships
        reflect_on_all_associations.map(&:name).each do |r_name|
        end
      end


    end

    protected

      def cache_prefix
        "#{self.class.cached_name}-#{self.id}"
      end

      #
      # clear cache if present
      #
      def clear_cache! caches_suffix_list= [], object_caches_suffix=[]
        object_caches_suffix= object_caches_suffix.blank?? self.class.object_caches_suffix : object_caches_suffix
        caches_suffix_list = caches_suffix_list.blank?? self.class.caches_suffix_list : caches_suffix_list

        caches_suffix_list.each do |cache_suffix|
          Rails.cache.delete("#{self.class.cached_name}-#{cache_suffix}")            
        end
        object_caches_suffix.each do |cache_suffix|
          Rails.cache.delete("#{cache_prefix}-#{cache_suffix}")            
        end

      end
    
  end
end