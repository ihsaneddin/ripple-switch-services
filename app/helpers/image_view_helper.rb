module ImageViewHelper 

  #
  # sugar method to display avatar
  #
  def user_avatar_image(url="/assets/adminLTE/img/user2-160x160.png", options={})
    image_tag url, { class: 'avatar-image', alt: 'User Image' }.merge!(options)
  end

end