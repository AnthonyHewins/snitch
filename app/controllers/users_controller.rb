require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/user_log'

class UsersController < ApplicationController
  include DataLogEndpoint
  
  def upload
  end

  # POST /users/upload
  def insert_data
    get_log UserLog, redirect: machines_path, fallback: users_upload_path
  end
end
