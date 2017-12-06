#
# this helper is used to render box div
#
module BoxPanelViewHelper

  #
  # to display box panel div
  # options are `use_footer`, `use_header`, `style`, `body_style`, `header`, `footer`
  # `suffix` is used to avoid double render with the same yield
  #
  def box_panel options={}, &block
    options= { suffix: suffix_template, header: nil, footer: nil, use_footer: true, use_header: true, body_style: nil}.merge!(options)
    box_panel_params(options[:suffix])
    instance_variable_set("@box_panel_params_#{options[:suffix]}", options)
    render layout: '/shared/box_panel/box_panel', locals: options do 
      yield(current_box= options[:suffix], options)
    end 
  end

  #
  # box panel header links
  #
  def box_panel_links options={ remove: false, collapse: false }
    content_tag :div, class: 'box-tools' do
      yield if block_given?
      concat(content_tag(:button, class: 'btn btn-box-tool', data: { widget: "collapse" }) do 
        content_tag :i, "", class: 'fa fa-minus'
      end) if options[:collapse]
      concat(content_tag(:button, class: "btn btn-box-tool", data: { widget: "remove" }) do
        content_tag(:i, "", class: "fa fa-times")
      end) if options[:remove]
    end
  end

  #
  # determine box panel style
  #
  def box_panel_style(suffix=nil)
    box_panel_params(suffix)[:style] || 'primary'
  end

  #
  # to store box_panel_header content
  #
  def box_panel_header(suffix=nil)
    box_panel_params(suffix)[:header] 
  end

  #
  # to store box_panel_footer content
  #
  def box_panel_footer(suffix=nil)
    box_panel_params(suffix)[:footer]
  end

  #
  # to set panel loading bar
  #
  def box_panel_loading?(suffix= nil)
    box_panel_params(suffix)[:loading] || false
  end

  #
  # add style to box body div
  #
  def box_panel_body_style(suffix)
    box_panel_params(suffix)[:body_style]
  end

  #
  # add style to box header div
  #
  def box_panel_header_style
    box_panel_params(suffix)[:header_style]
  end

  #
  # box_panel_params variable
  #
  def box_panel_params(suffix=nil)
    if instance_variable_get("@box_panel_params_#{suffix}").nil?
      instance_variable_set("@box_panel_params_#{suffix}", {})
    end
    instance_variable_get("@box_panel_params_#{suffix}")
  end

  #
  # to determine box_panel should use footer or not
  #
  def box_panel_use_footer?(suffix)
    box_panel_params(suffix)[:use_footer]
  end
  
  #
  # to determine box_panel should use header or not
  #
  def box_panel_use_header?(suffix)
    box_panel_params(suffix)[:use_header]
  end

end  