module NavViewHelper

  #
  # render nav top template
  #
  def nav_top_bar
    render layout: "/shared/navigation/topbar" do 
      yield if block_given?
    end
  end

  #
  # render nav sidebar template
  #
  def nav_side_bar
    render layout: "/shared/navigation/sidebar" do
      yield if block_given?
    end
  end

end