module TableViewHelper

  module Concern

    extend ::ActiveSupport::Concern

    def render_table file=nil
      if table_params_present?
        render file: file || "/shared/table/replace.js.erb", locals: table_params
      else
        yield
      end
    end

    def table_params_present?
      table_params.present?
    end

    def table_params
      params[:table]||= params.class.new.permit!
    end

  end

  def empty_table records, colspan=5, no_record="No record found."
    if records.blank?
      content_tag :tr, class: 'empty-table' do 
        content_tag :td, colspan: colspan do 
          content_tag :center, no_record
        end
      end
    end
  end

  #
  #always add prepend on div that contain table
  #append reload table link on data attribute on div that contain table
  #options are `id`, `resources_name`, `resources_url`
  #
  def table_container_for collection=[], options={}, &block
    if respond_to? :table_params
      params[:table]= params.class.new.permit! if params[:table].nil?
      options = { id: "table-container-for-#{controller_name}", template: "", resources_name: collection.first.class.name.demodulize.underscore.pluralize }.merge!(options)
      params[:table]= params[:table].merge!(params.class.new(options).permit!)
      content_tag :div, id: options[:id], data: { "reset-path": link_to("reset", current_url, class: 'hidden reset-table', remote: true) ,
                                                  "reload-path": link_to("reload", options[:resources_url].nil?? current_url( params.permit! ) : options[:resources_url], class: 'hidden reload-table', remote: true) } do 
        yield
      end
    end
  end

  #for append tr on table
  def append_tr td=[]
    content_tag(:tr) do 
      values= []
      td.each do |val|
        values << content_tag(:td) do 
                val.to_s
              end
      end
      values.join("\n").html_safe
    end
  end

  #table input params, useful for reloading table
  def table_input_params input_params=nil
    input_params ||= table_params
    content_tag(:div, class: "params-table") do 
      inputs = []
      input_params.each do |k,v|
        inputs << hidden_field_tag("table[#{k}]",v)
      end
      inputs.join("\n").html_safe
    end
  end

  def generate_table_input_params input_params={}
    table_input_params(input_params)
  end

  def table_params
    params[:table]||= params.class.new.permit!
  end

end