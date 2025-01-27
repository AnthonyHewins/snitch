require 'rails_helper'
require 'paper_trail'

RSpec.describe PaperTrail, type: :model do
  it {should have_many(:machines).dependent :destroy}
  it {should have_many(:uri_entries).dependent :destroy}
  it {should have_many(:whitelists).dependent :destroy}
  it {should have_many(:dhcp_leases).dependent :destroy}

  before :each do
    @obj = create :paper_trail
  end

  context ':insertion_date' do
    it 'should not allowed to be nil' do
      expect(build(:paper_trail, insertion_date: nil)).to_not be_valid
    end
  end
end
