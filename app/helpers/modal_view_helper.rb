module ModalViewHelper

  # this sub module can be included on controller
  module Concern

    extend ActiveSupport::Concern

    def render_modal file=nil
      if modal_params_present?
        render file: file || "/shared/modal/modal.js.erb", locals: modal_params
      else
        yield
      end
    end

    def dismiss_modal
      render file: "/shared/modal/dismiss.js.erb", locals: modal_params
    end

    def modal_params
      params[:modal]
    end

    def modal_params_present?
      modal_params.present?
    end

  end

  def modal options={}
    suffix= suffix_template
    options = {suffix: suffix, class: nil, id: "modal-#{suffix}", title: "Modal", submit_data: {}, use_footer: false, use_submit_footer_buttons: false, cancel_button_text: "Cancel", submit_button_text: "Submit" }.merge!(options)
    render layout: options[:layout] || default_modal_layout, template: modal_template, locals: options do 
      yield if block_given?
    end 
  end

  #
  # get modal params
  #
  def modal_params
    params[:modal] || {}
  end

  #
  # modal input params
  # include this method on any form tag that represented inside modal
  #
  def modal_input_params
    content_tag(:div, class: "params-modal") do 
      inputs = []
      modal_params.each do |k,v|
        if v.is_a?(String)
          inputs << hidden_field_tag("modal[#{k}]",v)
        else 
          has = v.try(:permit!).try(:to_h)
          if has.is_a? Hash
            v.each do |ke, va|
              inputs << hidden_field_tag("modal[#{k}][#{ke}]", va)
            end
          end
        end
      end
      inputs.join("\n").html_safe
    end
  end

  def modal_locals_template
    if modal_params[:resource_names].blank?
      {}
    else
      modal_params[:resource_names].split(",").each_with_object({}){| resource_name, hash | hash[resource_name.to_sym]= instance_variable_get(resource_name) } 
    end
  end

  def modal_template
    modal_params[:template] || "#{params[:controller]}/#{action_name}"
  end

  def default_modal_layout
    modal_params[:layout] || '/shared/modal/modal.html.erb'
  end

  #
  # too complex
  #
  module NotImplemented
    #
    # 
    #
    def simple_modal_for
      
    end

    #
    # initialize modal for resource template
    #
    def modal_for options={}
      options = options.merge!({ 
                                title: nil, footer: nil, use_header: true,
                                use_footer: true, use_submit_footer_buttons: true,
                                cancel_button_text: "Cancel", submit_button_text: "Submit"
                              })
      render layout: '/shared/modal/modal' do 
        yield if block_given?
      end
    end

    #
    # modal params
    # store any modal params
    # modal_params is consisted of : 
    # `modal_class`, `modal_id`, `use_header`, `use_footer`, 
    # `title`, `use_form`, `resource`, `content_template`, `form_url`,
    # `use_submit_footer_buttons`, ``
    #
    def modal_params
      params[:modal] || {}
    end

    #
    # modal input params
    # include this method on any form tag that represented inside modal
    #
    def modal_input_params
      content_tag(:div, class: "params-modal") do 
        inputs = []
        modal_params.each do |k,v|
          inputs << hidden_field_tag("modal[#{k}]",v)
        end
        inputs.join("\n").html_safe
      end
    end
  end

end