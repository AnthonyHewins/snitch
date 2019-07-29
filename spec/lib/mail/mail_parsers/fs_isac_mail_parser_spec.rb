require 'rails_helper'
require 'mail/mail_parsers/fs_isac_mail_parser'

RSpec.describe FsIsacMailParser do
  before :all do
    @alert = File.read 'spec/fixtures/fs_isac_alert.html'
  end

  context '#parse(string) returns in a dictionary' do
    before :all do
      @result = FsIsacMailParser.new.parse @alert
    end

    it 'the :title of the alert' do
      expect(@result[:title]).to eq 'Apache MINA Information Disclosure Vulnerability'
    end

    it 'the :tracking_id of the alert' do
      expect(@result[:tracking_id]).to eq "947023"
    end

    it 'the :risk of the alert' do
      expect(@result[:risk]).to eq 4
    end

    it 'the :alert_timestamp of the alert' do
      expect(@result[:alert_timestamp]).to eq "15 Apr 2019 04:00:00 UTC"
    end

    it 'the :alert of the alert' do
      expect(@result[:alert]).to eq "CVE References:\nCVE-2019-0231\n2019-04-15: At the time of this advisory, a description was not available.\nDetails:\n1) An error when handling close_notify SSL/TLS messages can be exploited to send otherwise encrypted messages in plaintext and subsequently disclose certain data.\nThe vulnerability is reported in versions prior to 2.0.21."
    end

    it 'the :affected_products of the alert' do
      expect(@result[:affected_products]).to eq "Apache MINA 2.x"
    end

    it 'the :corrective_action of the alert' do
      expect(@result[:corrective_action]).to eq "Update to version 2.0.21."
    end

    it 'the :sources of the alert' do
      expect(@result[:sources]).to eq "Original Advisory:\n:\nhttp://mail-archives.apache.org/mod_mbox/www-announce/201904.mbox/%3CCAG8=FRiDmUtkQOAe29SY9qHo8sMY9cB2djtp4BXk8Fi7uU+=YA@mail.gmail.com%3E\nAdvisory ID:\nSA88455\nCVE #:\nCVE-2019-0231"
    end
  end
end
