require_relative './data_log'
require_relative '../models/machine'

class CarbonBlackLog < DataLog
  FORMAT = "device_status_[0-9\-]*.csv" 

  def initialize(file, date_override: nil)
    super(file, true, date_override, nil, CarbonBlackLog) {|row| parse_row(row)}
  end

  private
  def parse_row(row)
    ip, host = row['lastInternalIpAddress'], row['name']
    begin
      machine = Machine.find_or_create_by ip: ip
      machine.update!(host: host, paper_trail: @date_override)
      @clean << machine
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end
end
