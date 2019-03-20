require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < ApplicationController
  def show
  end

  def index
    @machines = Machine.all
  end

  def upload
  end

  def insert_data
    filtered_params = params.permit(:carbon_black, :date_override)
    byebug
    log = CarbonBlackLog.new(
      filtered_params[:carbon_black].read,
      date_override: Date.parse(filtered_params[:date_override])
    )
    redirect_to machines_path
  end
end
