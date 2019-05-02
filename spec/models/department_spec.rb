require 'rails_helper'
require 'department'

RSpec.describe Department, type: :model do
  it {should have_many(:machines).dependent :restrict_with_exception}

  it 'should have ::CsvColumns equal to column_names' do
    expect(Department::CsvColumns).to eq Department.column_names
  end
end
