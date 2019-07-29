require_relative 'data_log'

class WhitelistLog < DataLog
  TIMESTAMP = /[0-9]+/
  FORMAT = /whitelist_log_#{TIMESTAMP.source}.csv/i
  GLOB_FORMAT = 'whitelist_log_[0-9]*.csv'

  def initialize(file, recorded: nil)
    super(file, true, recorded) {|row| parse_row(row)}
  end

  private
  def parse_row(row)
    begin
      wl = Whitelist.find_or_create_by regex_string: Regexp.new(row['regex_string']).to_s
      wl.update paper_trail: @recorded
    rescue Exception => e
      row['error'] = e
      @dirty << row
    end
  end
end
