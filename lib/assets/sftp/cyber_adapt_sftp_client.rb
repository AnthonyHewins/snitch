require 'date'

require_relative './sftp_client'
require_relative '../log_parsers/cyber_adapt_log'

class CyberAdaptSftpClient < SftpClient
  FIRST_DAY_OF_TRACKING = Date.new(2018, 10, 19)
  
  def initialize(host=nil, user=nil, opts={})
    super(
      host || 'remote.cyberadapt.com',
      user || 'flexplan',
      {port: 2222}.merge(opts)
    )
  end

  def pull(arg=nil, dir='.', &proc_filter)
    case arg
    when Date
      super(to_timestamped_filename(arg), dir, &proc_filter)
    when Range
      arg.map {|date| to_timestamped_filename(date)}
        .map {|str| super(str, dir, &proc_filter)}
    else
      super(arg, dir, &proc_filter)
    end
  end
  
  def pull_latest
    pull(CyberAdaptLog::FORMAT) do |file1,file2|
      file1.name < file2.name ? file2 : file1
    end
  end

  private
  def to_timestamped_filename(date)
    unless date.between? FIRST_DAY_OF_TRACKING, Date.today
      raise ArgumentError, "date must be between #{FIRST_DAY_OF_TRACKING} and today"
    end
    "flexplan_srcip_host_#{date.strftime("%Y%m%d")}.csv"
  end
end
