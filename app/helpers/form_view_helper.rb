#
# this helper is used to build form 
#
module FormViewHelper
  
  #
  # helper for print submit buttons wrapper
  #
  def submit_buttons_wrapper options= {}, &block 
    content_tag(:div, class: "form-group") do
      content_tag(:div, { class: "col-md-12 col-sm-12 col-xs-12 text-center #{options[:divider].present?? 'submit-buttons-wrapper-top-divider' : nil }" }.merge!(options)) do
        yield if block_given?
      end
    end
  end

  #
  # to assign `has-error` class to div.form-group
  #
  def has_error? obj, attribute
    obj.errors[attribute].present?? 'has-error' : nil
  end

  #
  # to display error validation
  #
  def display_error errors, *attributes
    unless errors.blank?
      attributes.each do |attribute|
        next if errors[attribute].blank? 
        concat(content_tag(:p, class: 'help-block') do 
          errors[attribute].join(', ')
        end)
      end
    end
    nil
  end

  def form_group_tag attribute, options={}
    options = { active: true, skip_error_message: false, strict: true }.merge!(options)
    if options[:active]
      if options[:strict]
        content_tag :div, class: "form-group has-feedback" do
          label= content_tag :label, class: "control-label #{options[:label_class] || 'col-sm-3'}" do
            if options[:label_name].present?
              options[:label_name].html_safe
            else
              attribute.to_s.titleize
            end
          end
          input= content_tag :div, class: options[:input_div_class] || 'col-sm-9' do 
            yield if block_given?
          end
          label.concat input
        end
      else
        content_tag :div, class: "form-group has-feedback" do
          yield if block_given?
        end
      end
    end
  end

  #
  # build form group
  #
  def form_group resource, attribute, options={}
    options = { active: true, skip_error_message: false, strict: true }.merge!(options)
    if options[:active]
      if options[:strict]
        content_tag :div, class: "form-group has-feedback #{has_error?(resource, attribute)}" do
          label= content_tag :label, class: "control-label #{options[:label_class] || 'col-sm-3'}" do
            if options[:label_name].present?
              options[:label_name].html_safe
            else
              attribute.to_s.titleize
            end
          end
          input= content_tag :div, class: options[:input_div_class] || 'col-sm-9' do 
            yield if block_given?
            unless options[:skip_error_message]
              display_error resource.errors, attribute
            end
          end
          label.concat input
        end
      else
        content_tag :div, class: "form-group has-feedback #{has_error?(resource, attribute)}" do
          yield if block_given?
        end
      end
    end
  end

  #
  # submit button params
  #
  def current_submit_params
    params[:submit] || params[:button]
  end

end