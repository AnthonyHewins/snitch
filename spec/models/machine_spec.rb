require 'rails_helper'
require 'machine'

RSpec.describe Machine, type: :model do
  it {should have_many :uri_entries}
  it {should belong_to(:paper_trail).required(false)}
  it {should validate_uniqueness_of(:ip).ignoring_case_sensitivity}
  it {should validate_uniqueness_of(:user).case_insensitive.allow_nil}
  it {should validate_uniqueness_of(:host).case_insensitive.allow_nil}

  before :each do
    @obj = create :machine
  end

  context 'before_save' do
    %i(user host).each do |sym|
      it "should downcase :#{sym} if non-nil" do
        @obj.update(sym => 'A')
        expect(@obj.reload.read_attribute sym).to eq 'a'
      end
    end

    it 'should remove the "flexibleplan\\" domain from :host, if present' do
      expect(create(:machine, host: 'flexibleplan\\A').host).to eq 'a'
    end
  end

  context '#to_a' do
    it 'maps each element in CsvColumns to make the machine ready for CSV output' do
      expect(@obj.to_a).to eq([
                                @obj.id,
                                @obj.user,
                                @obj.host,
                                @obj.ip,
                                @obj.paper_trail&.insertion_date,
                                @obj.created_at,
                                @obj.updated_at
                              ])
    end
  end
end
