require 'yaml'
require 'viewpoint'

require 'client/searchable'

class MailClient
  include Searchable

  USER = "reporting"
  ENDPOINT = "https://email.flexibleplan.com/ews/Exchange.asmx"

  def initialize(endpoint=ENDPOINT, user=USER, password=nil)
    if password.nil?
      secrets = YAML.load(File.open(Rails.root.join 'config/secrets.yml'))
      password = secrets['mail_password']
    end
    @endpoint, @user, @password = endpoint || ENDPOINT, user || USER, password
  end

  def pull(mailbox, opts={}, &filter)
    mail = pull_mailbox mailbox, opts[:from]
    find(mail, opts, &filter)
  end

  def pull_many(mailbox, opts={}, &filter)
    mail = pull_mailbox mailbox, opts[:from]
    filter(mail, opts, &filter)
  end

  protected
  def pull_mailbox(mailbox=:inbox, from=nil)
    items = Viewpoint::EWSClient.new(@endpoint, @user, @password)
              .get_folder(mailbox).items
    from.nil? ? items : items.select {|i| i.from.email == from}
  end
end
