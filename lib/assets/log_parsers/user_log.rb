require_relative './data_log'
require_relative Rails.root.join 'app/models/machine'

class UserLog < DataLog
  TIMESTAMP = /[0-9]+/
  FORMAT = /user_log_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = 'user_log_[0-9]*.csv'

  def initialize(file, date_override: nil, regex: nil)
    super(file, true, date_override, regex, UserLog) {|row| parse_row(row)}
  end

  def self.create_from_timestamped_file(file)
    UserLog.new(file, regex: TIMESTAMP)
  end

  private
  def parse_row(row)
    machine = Machine.find_by host: row['host'].downcase
    if machine.nil?
      row['error'] = ActiveRecord::RecordNotFound
                       .new("Unable to find a machine with this hostname.")
      @dirty << row
    else
      machine.update user: row['user'], paper_trail: @date_override
      @clean << machine
    end
  end
end
