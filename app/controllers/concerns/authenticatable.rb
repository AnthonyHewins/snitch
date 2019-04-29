require 'active_support/concern'

module Authenticatable
  class AccessDenied < Exception; end
  
  include ActiveSupport::Concern

  protected
  def check_if_logged_in
    raise AccessDenied if current_user.nil?
  end
end
