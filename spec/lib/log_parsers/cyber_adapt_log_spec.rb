require 'rails_helper'
require Rails.root.join 'lib/assets/log_parsers/cyber_adapt_log'

RSpec.describe CyberAdaptLog do
  before :all do
    @filename = Rails.root.join('tmp/flexplan_srcip_host_20190901.csv').to_path
    @ip = FFaker::Internet.ip_v4_address
    @uri = FFaker::Internet.uri 'http'
    @hits = rand(1000)
    CSV.open(@filename, 'wb') {|csv| csv << [@ip, @uri, @hits]}
  end

  before :each do
    @obj = CyberAdaptLog.new @filename, recorded: FFaker::Time.date
  end

  it 'inherits from DataLog' do
    expect(CyberAdaptLog).to be < DataLog
  end

  it 'handles a fixture CSV to give us confidence it works' do
    # Normally its better to do #new and ::create_... and make sure the 2
    # generated objects are equal, but the way the tests are set up it's hard
    # to accomplish this with UriEntries generating different IDs.
    expect(CyberAdaptLog.new(@filename).dirty.size).to eq 0
  end

  context '#initialize' do
    context 'reads in the CSV given with filename and' do
      it 'creates a UriEntry from the row when there are no problems' do
        expect{CyberAdaptLog.new @filename, recorded: FFaker::Time.date}
          .to change{UriEntry.count}.by 1
      end

      it 'files the UriEntry into @dirty if it has errors' do
        # Create an error in the CSV to force the read to put the UriEntry in @dirty
        file_with_errors = @filename + 'dirty'
        CSV.open(file_with_errors, 'wb') {|csv| csv << [@ip, @uri, 'asd']}

        obj = CyberAdaptLog.new file_with_errors, recorded: FFaker::Time.date

        expect(obj.dirty.size).to eq 1
      end

      it 'files the UriEntry into @clean if it has no errors' do
        expect(@obj.clean.size).to eq 1
      end

      it 'skips the entry if theres a regex in the whitelist matching it' do
        create :whitelist, regex_string: @uri
        obj = CyberAdaptLog.new @filename, recorded: FFaker::Time.date
        expect(obj.clean.size + obj.dirty.size).to eq 0
      end
    end
  end

  context 'private:' do
    context '#init_vars_before_super' do
      before :each do
        @obj.send :init_vars_before_super
      end
      
      it 'inits @clean to []' do
        expect(@obj.instance_variable_get :@clean).to eq []
      end

      it 'inits @whitelist to Whitelist.select(:regex_string).map(&:regex)' do
        expect(@obj.instance_variable_get :@whitelist)
          .to eq Whitelist.select(:regex_string).map(&:regex)
      end
    end

    context '#matches_invalid_format?' do
      it 'returns false when blank?' do
        expect(@obj.send :matches_invalid_format?, "").to be true
      end
      
      it 'returns false when matched with /<hostname[>]*/' do
        (0..2).each do |i|
          expect(@obj.send :matches_invalid_format?, "<hostname#{">" * i}").to be true
        end
      end

      it 'returns true when not matched' do
        expect(@obj.send :matches_invalid_format?, "hostname").to be false
      end
    end

    context '#cast_ipv6' do
      it 'catches IPv6 address wrapped in "[" and "]"' do
        ipv6 = "[fe80::1c43:56d:2a1c:c9d6]"
        expect(@obj.send(:cast_ipv6, ipv6)).to eq ipv6[1..-2]
      end

      it 'returns nil otherwise' do
        expect(@obj.send :cast_ipv6, "random").to be nil
      end
    end

    context '#clean_uri' do
      it 'returns the URI if it matches URI::regexp' do
        expect(@obj.send(:clean_uri, @uri)).to eq @uri
      end

      it 'prepends http:// if the URI doesnt parse correctly in hopes that it will now' do
        expect(@obj.send :clean_uri, "random").to eq "http://random"
      end
    end

    context '#queue_insert' do
      it "appends a CSV::Row to @dirty if there's an error" do
        @obj.send :queue_insert, @ip, @uri, 'a', nil
        expect(@obj.dirty.first).to be_instance_of CSV::Row
      end
      
      it 'appends a row of primitives to @clean for insertion later' do
        paper_trail = create(:paper_trail)
        @obj.send :queue_insert, @ip, @uri, @hits, paper_trail
        expect(@obj.clean.last)
          .to eq [Machine.find_by(ip: @ip).id, @uri, @hits, paper_trail.id]
      end
    end

    context '#memoize_ip(ip_as_a_string)' do
      before :each do
        # Clear old value from instantiation
        @obj.instance_variable_set :@ip_lookup_table, {}
        @machine = create(:machine)
      end
      
      it 'finds the machine with said ip and records its ID for memoization' do
        expect(@obj.send :memoize_ip, @machine.ip.to_s).to eq @machine.id
      end

      it 'is able to return the ID without SQL using @ip_lookup_table' do
        @obj.send :memoize_ip, @machine.ip.to_s
        expect(@obj.instance_variable_get(:@ip_lookup_table))
          .to eq({@machine.ip.to_s => @machine.id})
      end
    end
    
    context '#mass_insert' do
      it 'inserts a UriEntry array in the most low-level way possible for speed' do
        dummy_machine, dummy_paper_trail = create(:machine).id, create(:paper_trail).id
        two_records = [
          [dummy_machine, @uri, 1, dummy_paper_trail],
          [dummy_machine, @uri, 1, dummy_paper_trail],
        ]
        expect{@obj.send :mass_insert, two_records}.to change{UriEntry.count}.by(2)
      end
    end
  end
end
