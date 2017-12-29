module Supports
  module Settingable
    module Helpers
      module HasSetting
        
        extend ActiveSupport::Concern

        included do 

          class_attribute :setting_initialization_options

        end

        def cached_setting
          if self.class.respond_to?(:object_caches_suffix)
            Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-setting", expired_in: 1.day) do 
              setting
            end
          else
            setting
          end
        end

        #
        # give `#setting_name`_`#opt_key` default values when initializing persisted settingable object
        #
        def initialize_setting
          unless new_record?
            if cached_setting.nil?
              create_setting
              if self.class.respond_to?(:object_caches_suffix)
                clear_cache! caches_suffix_list= [], object_caches_suffix=["setting"]
              end
            end
            parameterize_name = setting_options[:name].downcase.parameterize.underscore
            setting_options[:options].except(:validations).keys.each do |opt_key|
              send("#{parameterize_name}_#{opt_key}=", cached_setting.get_setting_of(opt_key))
            end
          end
        end

        #
        # create setting object for settingable object
        #
        def create_setting
          if setting_options.is_a?(Hash)
            setting_options[:options][:validations] = setting_options[:validations]
            setting = Supports::Settingable::Models::Setting.new name: setting_options[:name]
            setting.options = setting_options[:options]
            setting.settingable= self
            setting.save
          end
        end

        #
        # save changes of setting key on settingable object to setting object options
        #
        def reinitialize_setting
          if setting.present?
            setting_options[:options].keys.each do |opt|
              setting.options[opt.to_sym]= send("#{setting_name}_#{opt}")
            end
            unless setting.save
              setting_options[:options].keys.each do |key|
                self.errors.add("#{setting_name}_#{key}".to_sym, setting.errors["option_#{key}".to_sym]) if setting.errors["option_#{key}"].any?
              end
              throw(:abort)
            end
          end
        end

        protected

          def setting_options
            self.class.setting_initialization_options
          end

          def setting_name
            "#{setting_options[:name].to_s.downcase.parameterize.underscore}"
          end

        module ClassMethods

          #
          # initialize setting object for settingable object
          #
          def define_setting opts={}
            opts = { name: "Setting", options: {}, validations: {}}.merge!(opts)
            self.setting_initialization_options= opts

            #define setting object relation
            has_one :setting, class_name: "Supports::Settingable::Models::Setting", :as => :settingable
            accepts_nested_attributes_for :setting, allow_destroy: false, reject_if: :all_blank

            # if settingable object implement Supports::Cacheable module
            if respond_to?(:object_caches_suffix)
              self.object_caches_suffix += ['setting']
            end

            #define attr_accessor for setting options
            parameterize_name = opts[:name].downcase.parameterize.underscore
            attr_accessor *opts[:options].keys.map{|opt_key| "#{parameterize_name}_#{opt_key}"}
            # flag to determine whether changed setting key is pushed to setting object
            attr_accessor :save_changed_setting

            send(:after_initialize, :initialize_setting)
            send(:after_create, :create_setting)
            send(:after_update, *[:reinitialize_setting, { if: :save_changed_setting }])
          end

        end

      end
    end
  end
end