module Supports
  module Settingable
    module Models
      class Setting < ApplicationRecord

        belongs_to :settingable, polymorphic: true

        #
        # serialize options attributes as hash
        #
        serialize :options, Hash

        #
        # generate option_#{option key} accessors like `option_ipn_key`
        # set option keys validations if present so the validations on options attribute is dynamic
        #
        after_initialize do
          initialize_options
        end

        after_save do
          initialize_options
        end

        #
        # initialize options keys as attr_accessor
        # 
        def initialize_options
          if options.present?
            opts = options.except(:validations)
            self.class.send(:attr_accessor, *opts.keys.map{|key| "option_#{key}" })
            opts.keys.each {|key| send("option_#{key}=", options[key]) }
            if options[:validations].present?
              options[:validations].each do |att, validation_opts|
                self.class.send(:validates, *[ "option_#{att}", validation_opts ])
              end
            end
          end
        end

        #
        # get value of given options attribute
        #
        def get_setting_of(key)
          options[key.to_sym] rescue nil
        end

      end
    end
  end
end