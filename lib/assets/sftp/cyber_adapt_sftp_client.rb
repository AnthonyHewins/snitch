require 'date'

require_relative './sftp_client'
require_relative '../log_parsers/cyber_adapt_log'

class CyberAdaptSftpClient < SftpClient
  def initialize(host=nil, user=nil, opts={})
    super(
      host || 'remote.cyberadapt.com',
      user || 'flexplan',
      {port: 2222}.merge(opts)
    )
  end

  def pull(arg=nil, dir='.', &proc_filter)
    super(duck_type_for_timestamped_filename(arg), dir, &proc_filter)
  end
  
  def pull_csv(*args)
    CSV.parse pull(*args)
  end

  def pull_latest
    pull(CyberAdaptLog::FORMAT) {|file1,file2| file1.name < file2.name ? file2 : file1}
  end

  def pull_latest_csv
    CSV.parse pull_latest
  end

  private
  def duck_type_for_timestamped_filename(possible_date)
    return possible_date unless possible_date.instance_of? Date
    "flexplan_srcip_host_#{possible_date.strftime("%Y%m%d")}"
  end
end
