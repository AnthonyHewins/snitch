require_relative 'data_log'
require 'machine'

class UserLog < DataLog
  TIMESTAMP = /[0-9]+/
  FORMAT = /inventory_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = 'inventory_[0-9]*.csv'

  def initialize(file, recorded: nil)
    super(file, true, recorded) {|row| parse_row(row)}
  end

  private
  def parse_row(row)
    host = row['Computer Name']
    return if host.nil?
    update_machine Machine.find_by(host: host.downcase), row
  end

  def update_machine(machine, row)
    if machine.nil?
      row['error'] = ActiveRecord::RecordNotFound
                       .new("Unable to find a machine with this hostname.")
      @dirty << row
    else
      machine.update user: row['Owner'], paper_trail: @recorded
    end
  end
end
