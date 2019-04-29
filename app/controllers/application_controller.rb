require 'concerns/authenticatable'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  helper_method :current_user

  rescue_from Authenticatable::AccessDenied do |e|
    flash[:error] = "You must be authenticated to access that resource, please log in."
    redirect_to login_path
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
