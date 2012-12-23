module ApplicationHelper

  def set_active_tab(target_controller)
    "active" if controller.controller_name == target_controller
  end
  
  def submit_button_with_image(label, image, button_class = "")
    content_tag :button, :type => :submit, :class => "button #{button_class}", :data => { :inline => "true" } do
      concat image_tag(image)
      concat label
    end
  end

  def button_with_link(label, image, link = "", id = "")
    link = "javascript:void(0)" if link.blank?
    link_to(link, :id => id, :class => "button") do
      concat image_tag(image)
      concat label
    end
  end
  
  def button_to_with_image(label, link, image, method = nil)
    method ||= :get
    form_tag link, :method => method do
      content_tag :button, :type => :submit, :class => "button", :data => { :inline => "true" } do
        concat image_tag(image)
        concat label
      end
    end
  end
  
  def differentiate_path(path, *args)
    attempt = request.parameters["attempt"].to_i + 1
    args.unshift(path).push(:attempt => attempt)
    send(*args)
  end
  
  def link_to_user_profile(user)
    link_to "#{user.name} (#{user.username})", profile_path(user.username)
  end
  
end
