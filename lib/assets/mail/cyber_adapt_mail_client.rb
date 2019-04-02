require 'yaml'

require_relative 'mail_client'

class CyberAdaptMailClient < MailClient
  USER = "reporting"
  ENDPOINT = "https://email.flexibleplan.com/ews/Exchange.asmx"
  ALERT_REGEX = /^\[cyberadapt.com #[0-9]+\] AutoReply: flexplan compromised/
  INFOSEC_EMAIL = "infosec1@cyberadapt.com"

  def initialize(endpoint=ENDPOINT, user=USER, password=nil)
    if password.nil?
      secrets = YAML.load(File.open(Rails.root.join 'config/secrets.yml'))
      password = secrets['mail_password']
    end
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

    super(:inbox, subject: arg, from: INFOSEC_EMAIL, &proc_filter)
  end

  def get_missing(ids_we_have_already)
    pull_mailbox(:inbox, INFOSEC_EMAIL).select do |email|
      subject = email.subject
      ALERT_REGEX.match?(subject) &&
        !ids_we_have_already.include?(Integer( /[0-9]+/.match(subject).to_s ))
    end
  end

  private
  def alert_id_to_mail_subject(alert_id)
    /[cyberadapt.com ##{alert_id}] AutoReply: flexplan compromised/
  end
end
