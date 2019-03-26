require 'rails_helper'
require_relative '../../../lib/assets/log_parsers/user_log'

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
      @row = CSV::Row.new(['Computer Name', 'Owner'], [@host, @user])
    end
    
    it 'returns if row["Computer Name"].blank?' do
      expect(@obj.send :parse_row, {}).to be nil
    end
    
    context 'when a machine is found case-insensitively' do
      before :each do
        @machine = create :machine, host: @host
      end
      
      it 'returns true on the success of machine.update' do
        expect(@obj.send(:parse_row, @row)).to be true
      end

      it 'it updates the paper trail' do
        @machine.update paper_trail: create(:paper_trail)
        @obj.send(:parse_row, @row)
        expect(@machine.reload.paper_trail).to be nil
      end

      it 'it updates the machine user' do
        previous = @machine.user
        expect{@obj.send(:parse_row, @row)}.to change{@machine.reload.user}
                                                 .from(previous).to(@user)
      end
    end

    it 'puts CSV::Rows that dont find a machine into @dirty and appends an ActiveRecord::RecordNotFound error' do
      @row['Computer Name'] = 'a'
      expect(@obj.send :parse_row, @row)
        .to eq [
              CSV::Row.new(
                ['Computer Name', 'Owner', 'error'],
                ['a', @user, ActiveRecord::RecordNotFound.new('Unable to find a machine with this hostname.')]
              )
            ]
    end
  end

  context '#update_machine(machine, row)' do
    context 'if machine.nil?' do
      before :each do
        @output = @obj.send(:update_machine, nil, {})
      end
      
      it 'appends ActiveRecord::RecordNotFound to row' do
        expect(@output.first['error']).to be_instance_of ActiveRecord::RecordNotFound
      end

      it 'appends the row to @dirty' do
        expect(@output.count).to be 1
      end
    end

    context 'if !machine.nil?' do
      it 'returns true if the update is successful on the machine' do
        expect(@obj.send :update_machine, create(:machine), {'Owner' => 'a'}).to be true
      end

      it 'updates machine.user (and downcases it, but not because of this class)' do
        machine = create :machine
        @obj.send :update_machine, machine, {'Owner' => 'B'}
        expect(machine.user).to eq 'b'
      end
    end
  end
end
