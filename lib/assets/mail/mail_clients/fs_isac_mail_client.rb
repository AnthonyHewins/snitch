require_relative 'mail_client'

class FsIsacMailClient < MailClient
  ALERT_REGEX = /^FW: CYV[0-9]{1}: [^\[]+\[FS-ISAC [A-z]*\]/

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
end
