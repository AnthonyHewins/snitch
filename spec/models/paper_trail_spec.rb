require 'rails_helper'
require 'paper_trail'

RSpec.describe PaperTrail, type: :model do
  it {should have_many(:machines).dependent :nullify}
  it {should have_many(:uri_entries).dependent :nullify}
  it {should have_many(:whitelists).dependent :nullify}

  before :each do
    @obj = create :paper_trail
  end

  context ':insertion_date' do
    it 'should not allowed to be nil' do
      expect(build(:paper_trail, insertion_date: nil)).to_not be_valid
    end
  end

  context '#to_a' do
    it 'maps each element in CsvColumns to make the machine ready for CSV output' do
      expect(@obj.to_a).to eq PaperTrail::CsvColumns.map {|i| @obj.send i}
    end
  end
end
