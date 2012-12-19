module ProfileHelper

  def avatar_label_with_error_message(label, user)
    message = [user.errors.messages[:avatar_file_size], user.errors.messages[:avatar_content_type]].flatten.select{ |m| m }.join(', ')
    label = %|<div class="fieldWithErrors">#{label} <span class="error">#{message}</span></div>|.html_safe unless message.blank?
    label
  end
  
end
