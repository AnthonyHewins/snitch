require_relative 'data_log'
require 'inet_loggable'
require 'machine'

class CarbonBlackLog < DataLog
  include InetLoggable
  
  TIMESTAMP = /[0-9\-]+/
  FORMAT = /device_status_#{TIMESTAMP}.csv/
  GLOB_FORMAT = "device_status_[0-9\-]*.csv"

  def initialize(file, recorded: nil)
    super(file, true, recorded) {|row| parse_row(row)}
  end

  private
  def parse_row(row)
    ip = row['lastInternalIpAddress']
    return if ip.blank?
    begin
      host = row['name'].downcase.gsub("flexibleplan\\", '')
      machine = Machine.find_or_create_by host: host
      machine.update!(paper_trail: @recorded)
      upsert_dhcp_lease ip, machine, @recorded
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end

  def upsert_dhcp_lease(ip, machine, paper_trail)
    lease = past_history_for_dhcp_lease(ip, paper_trail.insertion_date)
    if lease.nil?
      DhcpLease.create!(ip: ip, machine: machine, paper_trail: paper_trail)
    else
      lease.update!(machine: machine, paper_trail: paper_trail)
    end
  end
end
