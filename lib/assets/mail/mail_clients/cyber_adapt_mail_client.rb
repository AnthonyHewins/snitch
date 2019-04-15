require_relative 'mail_client'

class CyberAdaptMailClient < MailClient
  ALERT_REGEX = /^\[cyberadapt.com #[0-9]+\] AutoReply: flexplan/
  ALERT_SENDER = "infosec1@cyberadapt.com"

  def initialize(endpoint=nil, user=nil, password=nil)
    super endpoint, user, password
  end

  def pull(arg, &proc_filter)
    case arg
    when Integer
      arg = alert_id_to_mail_subject(arg)
    when String
    when Hash
      return super arg[:mailbox], arg, &proc_filter
    else
      raise TypeError, "must be Int, String or hash"
    end

    super(:inbox, subject: arg, from: ALERT_SENDER, &proc_filter)
  end

  def get_missing(ids_we_have_already)
    pull_mailbox(:inbox, ALERT_SENDER).select do |email|
      subject = email.subject
      ALERT_REGEX.match?(subject) &&
        !ids_we_have_already.include?(Integer( /[0-9]+/.match(subject).to_s ))
    end
  end

  private
  def alert_id_to_mail_subject(alert_id)
    /[cyberadapt.com ##{alert_id}] AutoReply: flexplan/
  end
end
