require_relative 'log_controller'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

class MachinesController < LogController
  def index
    @machines = Machine.all
  end

  # POST /machines/upload
  def insert_data
    carbon_black_log = get_log CarbonBlackLog, params
    redirect_to machines_path
  end
end
