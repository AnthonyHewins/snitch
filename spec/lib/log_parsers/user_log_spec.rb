require 'spec_helper'

RSpec.describe UserLog do
  before :all do
    @filename = Rails.root.join('tmp/user_log.csv').to_path
    CSV.open @filename, 'wb' do |csv|
      csv << ['host', 'user'] # header row
    end
  end
  
  before :each do
    @obj = UserLog.new @filename
  end
 
  context '#parse_row' do
    before :each do
      @host, @user = FFaker::Lorem.word, FFaker::Lorem.word
      @row = CSV::Row.new(['host', 'user'], [@host, @user])
    end
    
    context 'when a machine is found case-insensitively' do
      before :each do
        @machine = create :machine, host: @host
      end

      it 'it puts the machine in @clean' do
        @obj.send(:parse_row, @row)
        expect(@obj.clean).to eq [@machine]
      end

      it 'it updates the paper trail' do
        @machine.update paper_trail: create(:paper_trail)
        @obj.send(:parse_row, @row)
        expect(@obj.clean.first.paper_trail).to eq nil
      end

      it 'it updates the machine user' do
        previous = @machine.user
        expect{@obj.send(:parse_row, @row)}.to change{@machine.reload.user}
                                                 .from(previous).to(@user)
      end
    end

    it 'puts CSV::Rows that dont find a machine into @dirty and appends an ActiveRecord::RecordNotFound error' do
      @row['host'] = 'a'
      expect(@obj.send :parse_row, @row)
        .to eq [
              CSV::Row.new(
                ['host', 'user', 'error'],
                ['a', @user, ActiveRecord::RecordNotFound.new('Unable to find a machine with this hostname.')]
              )
            ]
    end
  end
end
