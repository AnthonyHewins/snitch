require_relative 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  include DataLogEndpoint
  
  def index
    @machines = filter Machine
    respond @machines
  end

  # POST /machines/upload
  def insert_data
    get_log CarbonBlackLog, redirect: machines_path, fallback: machines_upload_path
  end
end
