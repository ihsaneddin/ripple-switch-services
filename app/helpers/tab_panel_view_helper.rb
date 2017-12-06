module TabPanelViewHelper

  #
  # build tab panel
  # 
  #
  def tab_panel options={}, &block
    options= { suffix: suffix_template, list: [], active: nil }.merge!(options)
    instance_variable_set("@tab_panel_params_#{options[:suffix]}", options)
    render layout: "/shared/box_panel/tab_panel", locals: options  do 
      yield(current_tab= options[:suffix], options) if block_given?
    end
  end

  #
  # store tab build arguments
  #
  def tab_panel_params(suffix=nil)
    if instance_variable_get("@tab_panel_params_#{suffix}").nil?
      instance_variable_set("@tab_panel_params_#{suffix}", {})
    end
    instance_variable_get("@tab_panel_params_#{suffix}")
  end

  #
  # get tabs list
  #
  def tabs_list(suffix=nil)
    tab_panel_params(suffix)[:list] || []
  end

  #
  # to assign active class on specific tab
  #
  def is_tab_active?(suffix, tab)
    default_first = tab_panel_params(suffix)[:active] || tabs_list(suffix).first
    "active" if default_first == tab
  end

end