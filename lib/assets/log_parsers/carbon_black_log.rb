require_relative 'data_log'
require 'machine'

class CarbonBlackLog < DataLog
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
      machine = Machine.find_or_create_by host: row['name']
      machine.update!(paper_trail: @recorded)
      upsert_dhcp_history ip, machine
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end

  def upsert_dhcp_history(ip, machine)
    leases = past_history_for_dhcp_leases(ip)
    if leases.empty?
      DhcpLease.create!(ip: ip, machine: machine, paper_trail: @date_override)
    else
      leases.update_all(paper_trail: @date_override, machine: machine)
    end
  end

  def past_history_for_dhcp_leases(ip)
    DhcpLease.left_outer_joins(:paper_trails)
      .where(<<-SQL, date: @date_override.insertion_date, ip: ip).limit(1)
        paper_trails.insertion_date = :date
        and dhcp_leases.ip = :ip
      SQL
  end
end
