require 'rails_helper'
require Rails.root.join 'lib/assets/log_parsers/carbon_black_log'

RSpec.describe CarbonBlackLog do
  it 'inherits from DataLog' do
    expect(CarbonBlackLog).to be < DataLog
  end

  before :all do
    @filename = Rails.root.join('tmp/carbon_black_log.csv').to_path
    @ip, @name = FFaker::Internet.ip_v4_address, FFaker::Lorem.word
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
    before :each do
      @machine = create :machine
      @hash = {'lastInternalIpAddress' => @ip, 'name' => @machine.host}
    end

    context '#parse_row(row)' do
      it 'raises a NoMethodError unless row.respond_to? #[]' do
        expect{@obj.send :parse_row, Object.new}.to raise_error NoMethodError
      end

      it 'does nothing if row["lastInternalIpAddress"].blank?' do
        expect(@obj.send :parse_row, {'lastInternalIpAddress' => ""}).to be nil
      end
 
      context 'on no exception when the machine' do
        context 'exists with the specified hostname' do
          it 'uses the old instance' do
            expect{@obj.send :parse_row, @hash}.not_to change{Machine.count}
          end

          it 'replaces the PaperTrail that it points to' do
            @machine.update paper_trail: create(:paper_trail)
            @obj.send :parse_row, @hash
            expect(@machine.reload.paper_trail).to eq @obj.recorded
          end
        end

        context 'doesnt exist with the specified hostname' do
          it 'creates an instance of a machine with the IP and hostname' do
            @hash['name'] = 'something the database hasnt seen yet'
            expect{@obj.send :parse_row, @hash}.to change{Machine.count}.by(1)
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

    context '#upsert_dhcp_lease(ip, machine, paper_trail)' do
      it 'creates a DhcpLease if it doesnt find one because its a different IP' do
        expect {
          @obj.send :upsert_dhcp_lease, FFaker::Internet.ip_v4_address, @machine, @obj.recorded
        }.to change{DhcpLease.count}.by(1)
      end

      it 'creates a DhcpLease if it doesnt find one because its from a different day' do
        expect{
          @obj.send :upsert_dhcp_lease, @ip, @machine, create(:paper_trail)
        }.to change{DhcpLease.count}.by(1)
      end

      context 'when a lease is found by ip and paper_trail.insertion_date because it has internet history on that day' do
        before :each do
          paper_trail = create :paper_trail, insertion_date: @obj.recorded.insertion_date
          @lease = create :dhcp_lease, paper_trail: paper_trail
          @obj.send :upsert_dhcp_lease, @lease.ip, @machine, @obj.recorded
        end

        it 'updates the lease.paper_trail to be paper_trail' do
          expect(@lease.reload.paper_trail).to eq @obj.recorded
        end

        it 'updates the lease.machine to be machine' do
          expect(@lease.reload.machine).to eq @machine
        end
      end
    end
  end
end
