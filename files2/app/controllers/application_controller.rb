class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  
  before_filter :prep_mobile
  before_filter :set_locale
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_from_record_not_found
  
  private
  
  def is_mobile?
    # true
    !!(request.user_agent =~ /Mobile|webOS|iPhone/)
  end
  helper_method :is_mobile?
  
  def prep_mobile
    prepend_view_path "app/views/mobile" if is_mobile?
  end
  
  def set_locale
    I18n.locale = request.compatible_language_from(I18n.available_locales) || I18n.default_locale
  end
  
  def rescue_from_record_not_found(exception)
    model = exception.message.match(/Couldn't find (.*) with.*/)[1].downcase
    flash[:error] = t("errors.messages.model_id_not_found", :model => model)
    redirect_to (user_signed_in? && model != "user" ? url_for(model.classify.constantize) : root_path)
  end 
  
  def authenticate_user_with_ajax!
    unless current_user
      if request.xhr?
        render :js => "window.location = '#{new_user_session_path}'"
      else
        redirect_to new_user_session_path
      end
    end
  end
  
end
