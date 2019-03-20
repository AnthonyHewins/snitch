require_relative './data_log'
require_relative Rails.root.join 'app/models/machine'

class UserLog < DataLog
  FORMAT = "user_log_[0-9]*.csv"

  def initialize(file, date_override: nil)
    super(file, true, date_override, nil, UserLog) {|row| parse_row(row)}
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
