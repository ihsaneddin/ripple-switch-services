module Supports
  module Settingable
    module Helpers
      module HasOptions
        
        extend ActiveSupport::Concern

        included do 
          class_attribute :_options_mapping
          self._options_mapping = Hash.new
        end

        #
        # initialize options keys as attr_accessor
        # 
        def _initialize_options

          if _options_field.present?
            
            fields = _options_mapping_fields || {}
            prefix= self.class._options_mapping[:prefix]
            validations= _options_mapping_validations || {}
            fields.keys.each do |key|
               unless respond_to?("#{prefix}_#{key}")
                self.class.send(:attr_accessor, "#{prefix}_#{key}")            
                #class_eval %{
                #  def #{prefix}_#{key}=(val)
                #    send('#{_options_column}')['#{key}'.to_sym]= val
                #    super
                #  end
                #}                
              end
            end
            #self.class.send(:attr_accessor, *fields.keys.map{|key| "#{prefix}_#{key}" })
            
            fields.keys.each {|key| send("#{prefix}_#{key}=", _options_field[key]) if send("#{prefix}_#{key}").nil? }

            if validations.present?
              validations.each do |att, validation_opts|
                self.class.send(:validates, *[ "#{prefix}_#{att}", validation_opts ])
              end
            end

          end

        end

        def _sync_options
          _options_field.except(:validations).keys.each do |_key|
            send("#{_options_column}")[_key]= send("#{_options_prefix}_#{_key}") if respond_to?("#{_options_prefix}_#{_key}".to_sym)
          end
        end

        def _options_prefix
          return self.class._options_mapping[:prefix]
        end

        def _options_column
          self.class._options_mapping[:column]
        end

        def _options_field
          send(_options_column).blank?? self.class._options_mapping[:fields] : send(_options_column)
        end

        def _options_field=(val)
          return send("#{_options_field}=", val)
        end

        def _options_mapping_fields
          case self.class._options_mapping[:fields]
          when String, Symbol
            send(self.class._options_mapping[:fields])
          when Proc
            self.class._options_mapping[:fields].call(self)
          else
            self.class._options_mapping[:fields]
          end
        end

        def _options_mapping_validations
          case self.class._options_mapping[:validations]
          when String, Symbol
            send(self.class._options_mapping[:validations])
          when Proc
            self.class._options_mapping[:validations].call(self)
          else
            self.class._options_mapping[:validations]
          end           
        end

        module ClassMethods

          def has_options opts={}
            opts[:column]||= :options
            opts[:fields]||= {}
            opts[:validations]||= {}
            opts[:prefix]||= :option

            self._options_mapping= opts

            serialize opts[:column].to_sym, Hash

            if opts[:fields].is_a?(Hash)
              attr_accessor *opts[:fields].keys.map{|_key| "#{opts[:prefix]}_#{_key}" }
            end

            after_initialize do 
              _initialize_options
            end

            before_validation do 
              _sync_options
            end

            after_save do
              _initialize_options
            end

          end

        end

      end
    end
  end
end