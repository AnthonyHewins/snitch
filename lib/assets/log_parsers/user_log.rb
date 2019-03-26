require_relative './data_log'
require_relative Rails.root.join 'app/models/machine'

class UserLog < DataLog
  TIMESTAMP = /[0-9]+/
  FORMAT = /inventory_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = 'inventory_[0-9]*.csv'

  def initialize(file, date_override: nil, regex: nil)
    super(file, true, date_override, regex, UserLog) {|row| parse_row(row)}
  end

  def self.create_from_timestamped_file(file)
    UserLog.new(file, regex: TIMESTAMP)
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
      machine.update user: row['Owner'], paper_trail: @date_override
    end
  end
end
