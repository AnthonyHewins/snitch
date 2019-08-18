require 'rails_helper'
require 'department'

RSpec.describe Department, type: :model do
  it {should have_many(:machines).dependent :restrict_with_exception}
end
