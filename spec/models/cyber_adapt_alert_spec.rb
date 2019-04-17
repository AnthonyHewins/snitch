require 'rails_helper'
require 'cyber_adapt_alert'

RSpec.describe CyberAdaptAlert, type: :model do
  before :each do
    @obj = create :cyber_adapt_alert
  end

  before :all do
    @alert = File.read Rails.root.join 'spec/fixtures/cyber_adapt_alert.html'
  end

  it {should validate_inclusion_of(:alert_id).in_range(0..2147483647)}
  
  %i(alert_id alert msg src_ip src_port dst_ip dst_port alert_timestamp).each do |col|
    it {should validate_presence_of(col)}
  end

  %i(src_port dst_port).each do |port|
    it {should validate_inclusion_of(port).in_range(0..65535)}
  end

  context 'scope(:search)' do
    %i(msg alert_id src_ip dst_ip src_port dst_port).each do |sym|
      it "finds based on :#{sym}" do
        expect(CyberAdaptAlert.search @obj.send(sym)).to include @obj
      end
    end

    it 'finds based on :alert_timestamp' do
      expect(CyberAdaptAlert.search @obj.alert_timestamp.to_date).to include @obj
    end
  end

  context '::create_from_email(email)' do
    it 'creates directly from a raw string with the email' do
      expect{CyberAdaptAlert.create_from_email(@alert)}
        .to change{CyberAdaptAlert.count}.by(1)
    end

    it 'raises TypeError on other types' do
      expect{CyberAdaptAlert.create_from_email(1)}.to raise_error TypeError
    end
  end

  context ':msg' do      
    it 'does String#squish' do
      new_str = FFaker::Lorem.word + "\r\n 1 "
      @obj.update msg: new_str
      expect(@obj.msg).to eq new_str.squish
    end

    it 'replaces anything matching /&quot;|,/ with ""' do
      @obj.update msg: "&quot;,"
      expect(@obj.msg).to eq ''
    end
  end

  context ':alert' do      
    it 'does String#squish' do
      new_str = FFaker::Lorem.word + "\r\n 1 "
      @obj.update alert: new_str
      expect(@obj.alert).to eq new_str.squish
    end

    it 'replaces anything matching /&quot;|,/ with ""' do
      @obj.update alert: "&quot;,"
      expect(@obj.alert).to eq ''
    end
  end
end
