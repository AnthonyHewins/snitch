require 'rails_helper'
require Rails.root.join 'lib/assets/mail/mail_parsers/cyber_adapt_mail_parser'

RSpec.describe CyberAdaptMailParser do
  before :all do
    @alert = File.read Rails.root.join 'spec/fixtures/cyber_adapt_alert.html'
  end

  context '#parse' do
    before :each do
      @obj = CyberAdaptMailParser.new @alert
      @result = @obj.parse
    end

    it 'parses the :alert_id in the email' do
      expect(@result[:alert_id]).to eq '26038'
    end

    it 'parses the :src_ip in the email' do
      expect(@result[:src_ip]).to eq '192.168.11.81'
    end

    it 'parses the :dst_ip in the email' do
      expect(@result[:dst_ip]).to eq '87.246.143.242'
    end

    it 'parses the :src_port in the email' do
      expect(@result[:src_port]).to eq '52470'
    end

    it 'parses the :dst_port in the email' do
      expect(@result[:dst_port]).to eq '80'
    end

    it 'parses the :alert_timestamp in the email' do
      expect(@result[:alert_timestamp]).to eq "2019-03-28T15:41:24.000Z"
    end
  end
  
  context 'private:' do
    context '#copy_message_payload' do
      before :each do
        @payload = "<body></body><pre>payload</pre>"
        @obj = CyberAdaptMailParser.new @payload
      end

      it 'gets everything inside of the last HTML open/close tags it sees' do
        expect(@obj.send :copy_message_payload).to eq "payload"
      end

      it 'after it trims out bad chars, it dupes @string so future methods can mutate it without harming the copy' do
        expect(@obj.send(:copy_message_payload)).to_not be @obj.instance_variable_get :@string
      end
    end
  end
end
