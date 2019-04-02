require 'rails_helper'
require Rails.root.join 'lib/assets/mail/cyber_adapt_mail_parser'

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

  context "private:" do
    context '#find_then_eat(start, stop)' do
      before :each do
        @random = FFaker::Lorem.word
        @obj = CyberAdaptMailParser.new "1BEGIN#{@random}END1"
      end

      it 'returns everything between start and stop in @string' do
        expect(@obj.send :find_then_eat, "1BEGIN", "END1").to eq @random
      end

      it 'kills off all the text from @string that it seeked out for its target text' do
        @obj.send :find_then_eat, "1BEGIN", "END"
        expect(@obj.instance_variable_get :@string).to eq "1"
      end
    end

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

    context '#kill_off_everything_before(start)' do
      before :each do
        @word = FFaker::Lorem.words.join(' ')
        @obj = CyberAdaptMailParser.new @word
      end

      it 'returns @string if start.nil?' do
        expect(@obj.send :kill_off_everything_before, nil)
          .to be @obj.instance_variable_get :@string
      end

      it 'kills everything at and before start from @string' do
        expect(@obj.send :kill_off_everything_before, nil)
          .to be @obj.instance_variable_get :@string
      end
    end
  end
end
