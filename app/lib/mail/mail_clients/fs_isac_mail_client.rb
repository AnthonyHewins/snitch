require_relative 'mail_client'

class FsIsacMailClient < MailClient
  ALERT_REGEX = /^FW: CYV[0-9]{1}: [^\[]+\[FS-ISAC [A-z]*\]/
  BLACKLIST_REGEX = /^FW: CYT[0-9]{1}: MS-ISAC: Malware IPs and Domains observed/

  attr_reader :latest_date
  
  def initialize(endpoint=nil, user=nil, password=nil)
    super endpoint, user, password
  end

  def pull(arg, &proc_filter)
    case arg
    when String
      super(:inbox, subject: arg, &proc_filter)
    when Hash
      return super arg[:mailbox], arg, &proc_filter
    else
      raise TypeError, "arg must be String or opts hash"
    end
  end

  def get_missing(email_titles_of_things_we_have)
    pull_mailbox(:inbox).select do |email|
      ALERT_REGEX.match?(email.subject)
    end
  end

  def blacklist(latest_date=nil)
    @latest_date, blacklist = latest_date, nil
    filter_blacklists.each do |email|
      new_date = scan_date(email.subject)
      next unless @latest_date.nil? || new_date > @latest_date
      @latest_date, blacklist = new_date, email
    end
    blacklist
  end

  private
  def filter_blacklists
    pull_mailbox(:inbox).select {|i| BLACKLIST_REGEX.match?(i.subject)}
  end
  
  def scan_date(str)
    # The subject is of the form "... - DATE - ..."
    # Grab the date between the '-'
    Date.parse str[ str.index('-')..str.rindex('-') ].strip
  end
end
