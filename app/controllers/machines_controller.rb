require 'concerns/authenticatable'
require 'application_controller'
require Rails.root.join 'lib/assets/data_log_endpoint'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  include Authenticatable
  include DataLogEndpoint

  before_action :check_if_logged_in
  before_action :set_machine, only: %i(update edit destroy)

  def index
    @machines = filter Machine
    respond @machines
  end

  def create
    @machine = Machine.new machine_params

    if @machine.save
      flash[:info] = "Successfully created machine #{@machine.host}"
    else
      flash[:error] = @machine.errors
    end

    redirect_to machines_path
  end

  def update
    if @machine.update machine_params
      flash[:info] = "Successfully updated machine #{@machine.host}"
    else
      flash[:error] = @machine.errors
    end

    redirect_to machines_path
  end

  def destroy
    if @machine.destroy
      flash[:info] = "Machine #{@machine.host} successfully destroyed"
    else
      flash[:error] = @machine.errors
    end

    redirect_to machines_path
  end
  
  def insert_data
    get_log CarbonBlackLog, redirect: machines_path, fallback: machines_upload_path
  end

  private
  def machine_params
    params.require(:machine).permit :user, :host, :department_id
  end

  def set_machine
    @machine = Machine.find params[:id]
  end
end
