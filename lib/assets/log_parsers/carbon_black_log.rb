require_relative 'data_log'
require Rails.root.join 'app/models/machine'

class CarbonBlackLog < DataLog
  TIMESTAMP = /[0-9\-]+/
  FORMAT = /device_status_#{TIMESTAMP}.csv/
  GLOB_FORMAT = "device_status_[0-9\-]*.csv"

  def initialize(file, date_override: nil, regex: nil)
    super(file, true, date_override, regex) {|row| parse_row(row)}
  end

  def self.create_from_timestamped_file(file)
    CarbonBlackLog.new(file, regex: TIMESTAMP)
  end

  private
  def parse_row(row)
    ip, host = row['lastInternalIpAddress'], row['name']
    return if ip.blank?
    begin
      machine = Machine.find_or_create_by ip: ip
      machine.update!(host: host, paper_trail: @date_override)
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end
end
