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
    @obj = CarbonBlackLog.new @filename.to_s, recorded: FFaker::Time.date
  end

  it 'handles one of the fixture CSVs to give confidence that it works' do
    log = CarbonBlackLog.new Rails.root.join("spec/fixtures/device_status_2019-09-04.csv").to_s
    expect(log.dirty.size).to eq 0
  end

  context 'private:' do
    context '#parse_row(row)' do
      it 'raises a NoMethodError unless row.respond_to? #[]' do
        expect{@obj.send :parse_row, Object.new}.to raise_error NoMethodError
      end

      context 'on good data' do
        before :each do
          Machine.delete_all
          @machine = create :machine, ip: @ip
          @hash = {'lastInternalIpAddress' => @ip, 'name' => FFaker::Lorem.word}
        end

        context 'and in the DB already' do
          it 'uses the old instance if a machine exists with the IP from the file' do
            expect{@obj.send :parse_row, @hash}.not_to change{Machine.count}
          end

          it 'replaces the name of the machine' do
            expect{@obj.send :parse_row, @hash}
              .to change{@machine.reload.host}.from(@machine.host).to(@hash['name'])
          end

          it 'replaces the PaperTrail that it points to' do
            @machine.update paper_trail: create(:paper_trail)
            @obj.send :parse_row, {'lastInternalIpAddress' => @ip, 'name' => @host}
            expect(@machine.reload.paper_trail).to eq @obj.recorded
          end
        end

        context 'but not in the DB' do
          it 'creates an instance of a machine with the IP and hostname' do
            CarbonBlackLog.new @filename, recorded: FFaker::Time.date
            expect(Machine.find_by ip: @ip, host: @name).to_not be_nil
          end
        end

        it 'returns true on successful update' do
          expect(@obj.send :parse_row, @hash).to be true
        end
      end

      it 'in the event of an exception, << the CSV::Row to @dirty with its error attached' do
        @obj.send :parse_row, {'lastInternalIpAddress' => '1-', 'name': 'a'}
        expect(@obj.dirty.size).to eq 1
      end
    end
  end
end
