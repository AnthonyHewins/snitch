require 'rails_helper'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

RSpec.describe CarbonBlackLog do
  it 'inherits from DataLog' do
    expect(CarbonBlackLog).to be < DataLog
  end

  before :all do
    @filename = Rails.root.join('tmp/carbon_black_log.csv').to_path
    @ip = FFaker::Internet.ip_v4_address
    @name = FFaker::Lorem.word
    @paper_trail_id = create(:paper_trail).id
    CSV.open(@filename, 'wb') do |csv|
      csv << ['lastInternalIpAddress', 'name']
      csv << [@ip, @name]
    end
  end

  before :each do
    @obj = CarbonBlackLog.new @filename.to_s
  end

  it 'handles one of the fixture CSVs to give confidence that it works' do
    log = CarbonBlackLog.new Rails.root.join("spec/fixtures/carbon_black.csv").to_s
    expect(log.clean.size).to eq 234
  end

  context 'private:' do
    context '#parse_row' do
      it 'raises a NoMethodError if the arg doesnt respond_to #[]' do
        expect{@obj.send :parse_row, Object.new}.to raise_error NoMethodError
      end

      context 'on good data' do
        context 'and in the DB already' do
          before :each do
            Machine.delete_all
            @machine = create :machine, ip: @ip
          end

          it 'uses the old instance if a machine exists with the IP from the file' do
            expect{CarbonBlackLog.new @filename}.not_to change{Machine.count}
          end

          it 'replaces the name of the machine' do
            previous_name = @machine.host
            expect{CarbonBlackLog.new @filename}
              .to change{@machine.reload.host}.from(previous_name).to(@name)
          end

          it 'replaces the PaperTrail that it points to' do
            @machine.update paper_trail: create(:paper_trail)
            @obj.send :parse_row, {'lastInternalIpAddress' => @ip, 'name' => @host}
            expect(@machine.reload.paper_trail).to be nil
          end
        end

        context 'but not in the DB' do
          it 'creates an instance of a machine with the IP and hostname' do
            CarbonBlackLog.new @filename
            expect(Machine.find_by ip: @ip, host: @name).to_not be_nil
          end
        end

        it 'puts the record in @clean' do
          x = CarbonBlackLog.new @filename
          expect(x.clean.size).to eq 1
        end
      end

      it 'in the event of an exception, << the CSV::Row to @dirty with its error attached' do
        # Create a new CSV with a bad value for IP
        bad_data_path = @filename + 'dirty'
        CSV.open(bad_data_path, 'wb') do |csv|
          csv << ['lastInternalIPAddress', 'name']
          csv << ['a', 'asdasda']
        end
        expect(CarbonBlackLog.new(bad_data_path).dirty.size).to eq 1
      end
    end
  end
end
