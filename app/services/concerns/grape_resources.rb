#
# this module is used to fetch resource object (eg. user object, transaction object, etc) automatically based on context_resource model class and identifier params provided by url
# this module is also used to append current_editor to object to provide tracking changes of object if object#current_editor is defined
#
module Concerns
module GrapeResources
  extend ActiveSupport::Concern

  included do

    class_attribute :context_resource_class # to determine model class
    class_attribute :use_resource # to determine whether endpoints class automatically fetch resource object. default value is false
    class_attribute :identifier # to determine which params key is used to fetch resource object. default value is `id`
    class_attribute :friendly_id # to determine whether friendly_id `fetch` method will be used. default value is false
    class_attribute :includes_on_finder # includes relations when fetching object. default value is blank array
    class_attribute :context_resource # variable to contain resource object
    class_attribute :use_fetch # to determine whether identity cache `fetch` method will be used. default value is true 
    class_attribute :track_resource # to apply current_user object to context_resource#current_editor attribute. expect current_user helper method

    self.context_resource_class = nil
    self.use_resource = false
    self.identifier = :id
    self.friendly_id = false
    self.includes_on_finder = []
    self.use_fetch = true
    self.track_resource = false

    helpers HelperMethods
  end

  module HelperMethods

    def set_resource class_context
      class_eval do
        class_attribute :class_context
        self.class_context = class_context
      end
      #eval %{
      #  def #{resource_name}
      #    get_resource
      #  end
      #}
    end

    def context_resource
      @context_resource||= get_resource
    end

    def get_resource
      got_resource = identifier_param_present? ? existing_resource : new_resource
      after_get_resource(got_resource)
      #append_current_editor(got_resource)
    end

    def append_current_editor(got_resource)
      if self.track_resource and got_resource.respond_to?(:current_editor)
        got_resource.current_editor= current_user
      end
      got_resource
    end

    def after_get_resource(got_resource)
      #override this if you wish to add filter after getting resource
      got_resource
    end

    def new_resource
      resource_class_constant.new(resource_params)
    end

    def resource_params
      respond_to?("#{resource_name}_params") ? self.send("#{resource_name}_params") : {}
    end

    def identifier_param_present?
      params[class_context.identifier.to_sym].present?
    end

    def existing_resource
      resource_obj = existing_resource_finder
      if resource_obj.nil?
        raise ActiveRecord::RecordNotFound
      else
        resource_obj
      end
    end

    def existing_resource_finder
      if class_context.use_fetch and resource_class_constant.respond_to?(:fetch)
        if class_context.identifier.to_sym.eql?(:id)
          obj= resource_class_constant.fetch(params[class_context.identifier.to_sym])
        else
          obj= resource_class_constant.send("fetch_by_#{class_context.identifier}", params[class_context.identifier.to_sym]).first
        end
        obj
      else
        if friendly_identifier?
          resource_class_constant.friendly.includes(class_context.includes_on_finder).find(identifier_params)
        else
          resource_class_constant.includes(class_context.includes_on_finder).send("find_by", identifier_params)
        end
      end
    end

    def resource_class_constant
      @resource_class_constant||= class_exists?(resource_class) ? resource_class.constantize : raise {ActiveRecord::RecordNotFound}
    end

    def class_exists?(class_name)
       klass = Module.const_get(class_name)
        return klass.is_a?(Class) && klass < ActiveRecord::Base
      rescue NameError
        return false
    end

    def resource_class
      resource_class = self.class_context.context_resource_class
      if resource_class.nil?
        resource_class = class_context.name.demodulize.classify
      end
      resource_class
    end

    def resource_name
      if resource_class.is_a?(String)
        resource_class.demodulize.underscore.downcase
      else
        resource_class.name.demodulize.underscore.downcase
      end
    end

    def identifier_params
      identifier = class_context.identifier
      if identifier.is_a? Symbol
        par = {}
        par[identifier] = params[identifier]
        friendly_identifier? ? par[identifier] : par
      elsif identifier.is_a? Array
        Hash[identifier.map {|i|[i,params[i]]}]
      else
        {}
      end
    end

    def friendly_identifier?
      class_context.friendly_id
    end

  end

  module ClassMethods

    def resourceable
      if use_resource
        class_context = self
        before do
          set_resource class_context
        end
      end
    end

    def use_resource!
      self.use_resource = true
      resourceable
    end

  end

end
end