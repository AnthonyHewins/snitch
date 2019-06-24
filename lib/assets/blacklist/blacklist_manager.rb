require_relative '../mail/mail_parsers/ms_isac_blacklist_parser'
require_relative '../mail/mail_clients/fs_isac_mail_client'

class BlacklistManager
  DOMAIN_PATH = Rails.root.join "public/ms_isac/domains.txt"
  IP_PATH = Rails.root.join "public/ms_isac/ips.txt"

  def initialize
    @current_timestamp = find_current_timestamp
  end

  def update_blacklist
    client = FsIsacMailClient.new
    blacklist_email = client.blacklist @current_timestamp
    return if blacklist_email.nil?
    write_new_blacklists blacklist_email.body, client.latest_date
  end

  private
  def find_current_timestamp
    return nil unless File.exist? IP_PATH

    # The date which the blacklist was received is
    # in a comment at the top of the file, first 10
    # characters. Looks like "# 20190501\n..."
    Date.parse(File.read(IP_PATH, 10)[2..-1])
  end

  def write_new_blacklists(blacklist, date)
    parser = MsIsacBlacklistParser.new
    parser.parse blacklist
    write date, parser.ips, IP_PATH
    write date, parser.domains, DOMAIN_PATH
  end

  def write(date, array, path)
    f = File.open(path, 'w')
    f.write "# #{date.strftime("%Y%m%d")}\n"
    array.each {|i| f.write "#{i}\n"}
    f.close
  end
end
