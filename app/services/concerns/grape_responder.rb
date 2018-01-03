module Concerns
module GrapeResponder
  extend ActiveSupport::Concern

  included do

    class_attribute :presenter_name

    helpers do

      #
      # return message
      #
      def message options={}
        options = {status: "ok"}.merge!(options)
        status options[:status].to_sym || 201
        message||= options.delete(:message)
        {
          message: message
        }
      end

      #
      # return standard validation error from object
      #
      def standard_validation_object_error object = nil, options = { error: "Unprocessable entity" }
        if object.kind_of?(ActiveRecord::Base) || options[:detail].is_a?(Hash)
          options[:detail] = object.errors unless options[:detail].is_a?(Hash)
          error!(options, 422)
        end
      end

      #
      # return standard validation error from hash
      #
      def standard_validation_error options= {message: {}}
        options[:error]||= "Unprocessable entity"
        status = options.delete(:status)
        error!(options, status || options[:error].parameterize.underscore.to_sym || 422)
      end

      def standar_success_message options = {}

      end

      def standard_not_found_error options= { message: {} }
        options[:error]||= "Not Found"
        status = options.delete(:status)
        error!(options, status || options[:error].parameterize.underscore.to_sym || 404)
      end

      def standard_permission_denied_error
        error!({ error: "Unauthorized!"}, 401)
      end

      def presenter collection, options={}
        presenter_name = options.delete(:presenter_name) || self.try(:class_context).try(:presenter_name)
        if collection.is_a?(ActiveRecord::Relation)
          options[:root]||= :collection
          options[:parameters]= pagination_info(collection) if collection.respond_to?(:current_page)
          presenter_name ||= collection.model.name
        elsif collection.is_a?(ActiveRecord::Base)
          presenter_name ||= collection.class.name
        end
        ver = version.upcase
        begin
          presenter_class = "::Api::#{ver}::Presenters::#{presenter_name}".constantize
        rescue NameError
          presenter_class = "::Api::#{ver}::Presenters::#{presenter_name.demodulize}".constantize
        end
        present collection, with: presenter_class, parameters: options[:parameters], root: options[:root]
      end

      def direct_present object, options={}
        with = options.delete(:with)
        if object.respond_to?(:map)
          object.map { |obj| with.new(obj) }
        else
          with.new(object)
        end
      end

      #
      # @Override from Grape::DSL::InsideRoute
      #
      def present *args
        options = args.count > 1 ? args.extract_options! : {}
        key, object = if args.count == 2 && args.first.is_a?(Symbol)
                        args
                      else
                        [nil, args.first]
                      end
        entity_class = entity_class_for_obj(object, options)

        root = options.delete(:root)
        parameters = options.delete(:parameters)

        representation = if entity_class
                           entity_representation_for(entity_class, object, options)
                         else
                           object
                         end

        representation = { root => representation } if root
        
        if representation.is_a?(Array) and parameters.present?
          representation = { data: representation }
        end
        representation = representation.merge!(parameters) if representation.is_a?(Hash)
        if key
          representation = (@body || {}).merge(key => representation)
        elsif entity_class.present? && @body
          raise ArgumentError, "Representation of type #{representation.class} cannot be merged." unless representation.respond_to?(:merge)
          representation = @body.merge(representation)
        end

        body representation
      end

      def pagination_info(collection)
        {
          current_page: collection.current_page,
          last_page: collection.current_page >= collection.total_pages,
          total_pages: collection.total_pages,
          per_page: params[:per_page] || 20,
          total_records: collection.try(:count) || collection.try(:length)
        }
      end

    end
  end
end
end