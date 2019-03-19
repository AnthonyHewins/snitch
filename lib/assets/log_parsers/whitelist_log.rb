require_relative './data_log'

class WhitelistLog < DataLog
  FORMAT = "whitelist_[0-9]*"

  def initialize(file, date_override: nil)
    super(file, true, date_override, nil, WhitelistLog) {|row| parse_row(row)}
  end

  private
  def parse_row(row)
    begin
      @clean << Whitelist.find_or_create_by(
        regex_string: Regexp.new(row['regex_string']).to_s
      )
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end
end
