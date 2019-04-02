require 'viewpoint'

require_relative '../client/searchable'

class MailClient
  include Searchable

  def initialize(endpoint, user, password)
    @endpoint, @user, @password = endpoint, user, password
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
