require 'securerandom'

module Supports
  module EncryptedRequests
    module Helpers
      module EncryptRequest

        extend ActiveSupport::Concern

        module Model

          extend ActiveSupport::Concern

          included do
            class_attribute :_encrypted_requests
            self._encrypted_requests = Hash.new{|k,v| k[v]= [] }
          end

          def create_encrypted_request_for att= nil
            _builder = self._encrypted_requests[att.to_sym]
            return unless _builder
            _builder.record= self
            _builder.create
          end

          module ClassMethods

            def encrypt_request_for *args

              options = args.extract_options!.dup
              attribute = args[0]

              raise ArgumentError, "You need to supply the \`attribute\` param as first argument" if attribute.nil?
              raise ArgumentError, "You need to supply the \`key\` option" if options[:key].nil?
              raise ArgumentError, "You need to supply the \`data\` option" if options[:data].nil?
              raise ArgumentError, "You need to supply the \`requester\` option" if options[:requester].nil?

              encrypt_each(attribute, options)

            end

            def encrypt_each(attribute, options)
              self._encrypted_requests[attribute.to_sym]= EncryptionRequestBuilder.new(options)
            end

            class EncryptionRequestBuilder

              attr_accessor :key, :salt, :data, :requester, :record

              def initialize opts={}
                self.key= opts[:key]
                self.salt= opts[:salt]
                self.data= opts[:data]
                self.requester= opts[:requester]
                self.record= opts[:record]

                [:key, :data, :requester].each do |_key|
                  class_eval %{
                    def #{_key}
                      #{_key}= instance_variable_get("@#{_key}")
                      case #{_key}
                      when Proc
                        #{_key}.call(record)
                      when Symbol
                        record.try(:send, #{_key})
                      when String
                        #{_key}
                      end
                    end
                  }
                end
              end

              def salt
                _key= instance_variable_get("@salt")
                case _key
                when Proc
                  _key.call(record)
                when Symbol, String
                  record.send(_key)
                else
                  SecureRandom.hex(64)
                end
              end

              def create
                _requested_encryption = Supports::EncryptedRequests::Models::EncryptedRequest.create given_key: key, given_salt: salt, given_data: data, requester: requester, context: record
              end

            end

          end

        end

        module Controller

          extend ActiveSupport::Concern

          included do

            helper_method :encrypted_request, :context, :requester
            before_action :valid_request

          end

          def show
            respond_to do |f|
              f.html
              f.js
            end
          end

          def decrypt
            @message = encrypted_request.decrypt(given_key: decrypt_params[:pin], given_salt: decrypt_params[:salt])
            respond_to do |f|
              f.html
              f.js
            end
          end

          def encrypted_request
            @encrypted_request||= Supports::EncryptedRequests::Models::EncryptedRequest.available.find(params[:id])
          end

          def context
            @context||= @encrypted_request.try(:context)
          end

          def requester
            @requester||= @encrypted_request.try(:requester)
          end

          def decrypt_params
            params.permit(:pin, :salt)
          end

          def valid_request
            if encrypted_request.is_expired?
              raise ActiveRecord::RecordNotFound
            end
          end

        end

      end
    end
  end
end