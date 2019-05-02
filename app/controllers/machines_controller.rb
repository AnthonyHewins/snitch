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

  def edit
    @machine = Machine.find params[:id]
  end

  def update
    machine = Machine.find params[:id]
    if machine.update machine_params
      flash[:info] = "Successfully updated machine #{machine.host}"
      redirect_to machines_path
    else
      flash[:error] = machine.errors
      redirect_to machine
    end
  end
  
  def insert_data
    get_log CarbonBlackLog, redirect: machines_path, fallback: machines_upload_path
  end

  private
  def machine_params
    params.permit :department_id
  end
end
