require 'date'

require_relative 'sftp_client'

class CyberAdaptSftpClient < SftpClient
  FIRST_DAY_OF_TRACKING = Date.new(2018, 10, 19)
  ENDPOINT = 'remote.cyberadapt.com'
  USER = 'flexplan'

  def initialize(host=nil, user=nil, opts={})
    opts[:port] = 2222 unless opts.key? :port
    super(host || ENDPOINT, user || USER, opts)
  end

  def pull(arg, &proc_filter)
    case arg
    when Date
      date_check arg
      super(name: to_timestamped_filename(arg), &proc_filter)
    when Range
      date_check arg.first, arg.last
      arg.map {|date| super(name: to_timestamped_filename(arg), &proc_filter)}
    when String
      super(name: arg, &proc_filter)
    else
      super(arg, &proc_filter)
    end
  end

  def get_missing
    missing_dates.map {|date| pull date}
  end

  def missing_dates
    (FIRST_DAY_OF_TRACKING..(Date.today - 1)).to_a - PaperTrail.pluck(:insertion_date)
  end

  private
  def date_check(*dates)
    today = Date.today
    dates.each do |date|
      unless date.between? FIRST_DAY_OF_TRACKING, today
        raise ArgumentError, "date must be between #{FIRST_DAY_OF_TRACKING} and today"
      end
    end
  end

  def to_timestamped_filename(date)
    "flexplan_srcip_host_#{date.strftime("%Y%m%d")}.csv"
  end
end
