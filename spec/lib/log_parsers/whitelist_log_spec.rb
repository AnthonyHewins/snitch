require 'rails_helper'
require Rails.root.join 'lib/assets/log_parsers/whitelist_log'

RSpec.describe WhitelistLog do
  before :all do
    @filename = Rails.root.join('tmp/whitelist_log.csv').to_path
    @regex = FFaker::Lorem.word + "[0-9]*"
    CSV.open(@filename, 'wb') do |csv|
      csv << ['regex_string']
      csv << [@regex]
    end
  end

  before :each do
    @obj = WhitelistLog.new(@filename)
  end
  
  it 'inherits from DataLog' do
    expect(WhitelistLog).to be < DataLog
  end

  context 'private:' do
    context '#parse_row(row)' do
      it 'returns the Whitelist entry if it succeeds in insertion' do
        expect(@obj.send :parse_row, {'regex_string' => @regex}).to be_instance_of Whitelist
      end

      it 'creates the whitelist element if the regex is valid' do
        expect{@obj.send :parse_row, {'regex_string' => "a[0-9]*"}}
          .to change{Whitelist.count}.by 1
      end

      it 'doesnt create the whitelist element if it exists already' do
        expect{@obj.send :parse_row, {'regex_string' => @regex}}
          .not_to change{Whitelist.count}
      end

      it 'files the Whitelist into @dirty if it has errors' do
        expect{@obj.send :parse_row, {'regex_string' => "[0-"}}
          .to change{@obj.dirty.size}.by 1
      end
    end
  end
end
