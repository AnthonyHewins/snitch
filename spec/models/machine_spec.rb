require 'spec_helper'
require 'machine'

RSpec.describe Machine, type: :model do
  it {should have_many :uri_entries}
  it {should belong_to(:paper_trail).required(false)}
  it {should validate_uniqueness_of(:ip).ignoring_case_sensitivity}
  it {should validate_uniqueness_of(:user).case_insensitive.allow_nil}
  it {should validate_uniqueness_of(:host).case_insensitive.allow_nil}

  context 'before_save' do
    it 'should downcase the user if non-nil' do
      expect(create(:machine, user: 'A').user).to eq 'a'
    end

    it 'should downcase the host if non-nil' do
      expect(create(:machine, host: 'A').host).to eq 'a'
    end

    it 'should remove the "flexibleplan\\" domain from the host, if present' do
      expect(create(:machine, host: 'flexibleplan\\A').host).to eq 'a'
    end
  end
end
