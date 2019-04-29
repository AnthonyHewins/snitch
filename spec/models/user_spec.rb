require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @pw = FFaker::BaconIpsum.characters(20)
    @user = create(:user, password: @pw)
  end
  
  it {should have_secure_password}
  it {should validate_uniqueness_of :name}
  it {should validate_presence_of :name}
end
