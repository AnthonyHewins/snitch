require 'rails_helper'
require 'uri_entry'

RSpec.describe UriEntry, type: :model do
  before :each do
    @obj = create :uri_entry
  end
  
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

  context '#machine' do
    it 'returns the machine tied to :dhcp_lease' do
      expect(@obj.machine).to eq Machine.find @obj.dhcp_lease.machine_id
    end
  end
end
