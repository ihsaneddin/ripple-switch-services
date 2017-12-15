module ApplicationHelper

  #
  # to avoid yield with the same name
  # append this suffix 
  #
  def suffix_template
    SecureRandom.hex
  end

  #
  # sugar method for content_for with suffix template
  #
  def _content_for(suffix,section, &block)
    content_for("#{section}_#{suffix}".to_sym) do 
      yield
    end
  end

  #
  # sugar method for content_for
  #
  def yield_content_for section, content
    content_for section do 
      content
    end
  end

  #
  # bootstrap flash message helper methods
  #
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-danger", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible text-center fade in") do 
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message 
            end)
    end
    nil
  end

  #
  # end of bootstrap flash message helper methods
  #

  #
  # display image if present
  # alternative image is provided
  #
  def image_tag_display(main_image, alt_image, options={})
    image_path = alt_image
    if asset_exists?(main_image)
      image_path= main_image
    end
    image_tag image_path, options
  end

  #
  # check whether asset is exist
  #
  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  def current_url(new_params={})
    params.merge!(new_params)
    "#{request.base_url + request.path}?#{params.permit!.to_param}"
  end

end
