require 'concerns/authenticatable'
require 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  include Authenticatable
  include DataLogEndpoint
  
  before_action :check_if_logged_in

  def index
    @machines = filter Machine
    respond @machines
  end

  def insert_data
    get_log CarbonBlackLog, redirect: machines_path, fallback: machines_upload_path
  end
end
