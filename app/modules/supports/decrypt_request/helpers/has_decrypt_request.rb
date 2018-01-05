module Supports
  module DecryptRequest
    module Helpers
      module HasDecryptRequest
        
        extend ActiveSupport::Concern

        included do

          class_attribute :_requested_decryption

          self._requested_decryption = Hash.new{|k,v| k[v]= [] }

        end

        def create_decrypt_request_for att
          builder = self.class._requested_decryption[att.to_sym]
          unless builder.blank?
            
          end
        end

        def decrypt_for(key)
          
        end

        module ClassMethods

          def request_for_decrypt *opts
            options = opts.extract_options!.dup
            attribute = opts[0]
            
            raise ArgumentError, "You need to supply the \`attribute\` param as first argument" if attribute.nil?
            raise ArgumentError, "You need to supply the \`key\` option" if options[:key].nil?

            decrypt_each(attribute, options)

          end

          def decrypt_each(attribute, opts)
            self._requested_decryption[attribute.to_sym]= DecryptionRequestBuilder.new(opts)
          end

          private

            def _valid_request_decrypt_options
              [ :key, :expired_in]
            end

        end

        class DecryptionRequestBuilder

          attr_accessor :key, :expired_in, :record, :request

          def initialize(options={})
            [:key, :expired_in, :record].each{|_key| send("#{_key}=", options[_key]) }
            
            [:key, :expired_in].each do |_key|
              class_eval %{
                def #{_key}
                  _key= instance_variable_get("@#{_key}")
                  case _key
                  when Proc
                    _key.call(record)
                  when Symbol
                    record.try(:send, _key)
                  when String
                    _key
                  end
                end
              }
            end
          end

          def decrypt_field *args
            field,request= args
          end

          def create
            request||= Supports::DecryptRequest::Models::Request.create key: key, expired_in: expired_in
          end

        end

      end
    end
  end
end