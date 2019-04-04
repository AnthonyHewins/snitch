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
    @obj = WhitelistLog.new @filename, date_override: FFaker::Time.date
  end

  it 'inherits from DataLog' do
    expect(WhitelistLog).to be < DataLog
  end

  context 'private:' do
    context '#parse_row(row)' do
      it 'sets the whitelists paper_trail to @date_override' do
        paper_trail = create :paper_trail
        @obj.instance_variable_set :@date_override, paper_trail
        @obj.send :parse_row, {'regex_string' => @regex}
        expect(Whitelist.first.paper_trail).to eq paper_trail
      end

      it 'returns the Whitelist entry if it succeeds in updating' do
        expect(@obj.send :parse_row, {'regex_string' => @regex}).to be true
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
