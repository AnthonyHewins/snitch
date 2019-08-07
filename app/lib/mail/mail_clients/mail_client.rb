require 'yaml'
require 'erb'
require 'viewpoint'

require 'client/searchable'

class MailClient
  include Searchable

  USER = "reporting"
  ENDPOINT = "https://email.flexibleplan.com/ews/Exchange.asmx"

  def initialize(endpoint=ENDPOINT, user=USER, password=nil)
    @endpoint = endpoint || ENDPOINT
    @password = password || load_yaml['mail_password']
    @user = user || USER
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

  def load_yaml
    YAML.load(
      ERB.new(
        File.read(Rails.root.join 'config/secrets.yml')
      ).result
    )
  end
end
