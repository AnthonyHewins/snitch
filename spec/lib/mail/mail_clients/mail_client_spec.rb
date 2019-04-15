require 'rails_helper'
require Rails.root.join 'lib/assets/mail/mail_clients/mail_client'
require Rails.root.join 'lib/assets/mail/mail_clients/cyber_adapt_mail_client'

RSpec.describe MailClient do
  before :each do
    @obj = MailClient.new(
      CyberAdaptMailClient::ENDPOINT,
      CyberAdaptMailClient::USER,
      YAML.load( File.open(Rails.root.join 'config/secrets.yml') )['mail_password']
    )
  end

  subject {MailClient}
  it {should include Searchable}

  context 'protected:' do
    context '#pull_mailbox(mailbox=:inbox, from=nil)' do
      it 'filters everything not sent from the person in the "from" field' do
        from = "infosec1@cyberadapt.com"
        items = @obj.send :pull_mailbox, :inbox, from
        expect(items.all? {|i| i.from.email == from}).to be true
      end
    end
  end
end
