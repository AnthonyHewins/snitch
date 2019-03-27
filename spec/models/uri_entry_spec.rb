require 'rails_helper'
require 'uri_entry'

RSpec.describe UriEntry, type: :model do
  before :each do
    @obj = create :uri_entry
  end
  
  it {should belong_to :machine}
  it {should belong_to(:paper_trail).required(false)}

  context ':hits' do
    it 'is invalid when not an integer' do
      expect(build :uri_entry, hits: 9.1).to be_invalid
    end

    it 'is invalid when not at least 1' do
      (-1..0).each {|i| expect(build :uri_entry, hits: i).to be_invalid}
    end

    it 'allows natural numbers smaller than the PSQL largest int' do
      expect(build :uri_entry, hits: 10).to be_valid
    end
  end

  context ':uri' do
    it "allow anything in FFaker::Internet.uri('http'), so any http URI" do
      expect(create :uri_entry).to be_valid # FactoryBot + FFaker does this already
    end

    it "shouldn't allow anything not matching URI::regexp" do
      expect(build :uri_entry, uri: FFaker::Lorem.unique.word).to be_invalid
    end
  end

  context '#url' do
    it 'proxies for the :uri attribute, using the URI class' do
      expect(@obj.url).to be_a URI
    end

    it "memoizes :uri's value with the instance var @url" do
      expect(@obj.instance_variable_get :@url).to eq URI(@obj.uri)
    end
  end

  context '#uri=' do
    it "updates @url's value to maintain synchronization" do
      @obj.uri = "http://newuri.com"
      expect(@obj.url).to eq URI(@obj.uri)
    end
  end

  context '#to_a' do
    it 'maps each element in CsvColumns to make the machine ready for CSV output' do
      expect(@obj.to_a).to eq([
                                @obj.id,
                                @obj.machine.ip,
                                @obj.machine.user,
                                @obj.machine.host,
                                @obj.uri,
                                @obj.hits,
                                @obj.paper_trail&.insertion_date,
                                @obj.created_at,
                                @obj.updated_at
                              ])
    end
  end
  
  context '::[]' do
    context 'on Integer input' do
      it 'finds the history with machine_id == arg when it exists' do
        expect(UriEntry[@obj.machine.id]).to match_array UriEntry.where id: @obj.id
      end

      it 'returns an empty relation when theres no history for the machine_id' do
        expect(UriEntry[0]).to match_array UriEntry.where id: -1
      end
    end

    context 'on machine input' do
      it 'does a UriEntry.where machine: arg' do
        expect(UriEntry[@obj.machine]).to match_array UriEntry.where id: @obj.id
      end
    end

    context 'on IPAddr input' do
      it 'finds the machine with that IP and gets its history' do
        ip = @obj.machine.ip
        expect(UriEntry[ip]).to match_array UriEntry.where machine: Machine.find_by(ip: ip)
      end

      it 'returns an empty relation if the IP isnt associated with a machine' do
        expect(UriEntry[IPAddr.new('0.0.0.0')]).to match_array UriEntry.where id: -1
      end
    end

    context 'on String input' do
      it 'treats IP strings differently to account for PSQL inet types and finds off that' do
        ip = @obj.machine.ip.to_s
        expect(UriEntry[ip]).to match_array UriEntry.where machine: Machine.find_by(ip: ip)
      end

      it 'returns an empty relation if no machine exists' do
        expect(UriEntry['']).to match_array UriEntry.where id: -1
      end
    end

    it 'raises TypeError on any class type not recognized above' do
        expect{UriEntry[Object.new]}.to raise_error TypeError
    end
  end
end
